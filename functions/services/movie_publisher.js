/* eslint-disable max-len, valid-jsdoc */
const admin = require("firebase-admin");
const crypto = require("crypto");
const {BOX_OFFICE_KR_SHEET, BOX_OFFICE_USA_SHEET, buildOriginSource, buildMovieMetadata, hasCountrySheet, readBoxOfficeSheet, readCountrySheet, readSpecialDataSheet, replaceBoxOfficeSheet, replaceCountrySheet, replaceSpecialDataSheet} = require("./movie_sheet");

const BOX_OFFICE_USA_COUNTRIES = new Set(["box_office", "box_office_usa", "box_office-usa"]);
const BOX_OFFICE_KR_COUNTRIES = new Set(["box_office_kr", "box-office-kr"]);
// Large scheduled imports (for example, France with roughly 150 rows) need
// substantially longer than a limited test run for all GOOGLETRANSLATE
// formulas to settle. Keep polling rather than publishing partial data.
const TRANSLATION_POLL_INTERVAL_MS = 15000;
const TRANSLATION_POLL_ATTEMPTS = 16;

/** Returns whether a processed movie can be included in published data. */
function isPublishableMovie(movie) {
  if (!movie) return false;
  const trailerUrl = String(movie.trailerUrl || "").trim();
  const posterUrl = String(movie.posterUrl || "").trim();
  return trailerUrl !== "" && trailerUrl !== "ERR404" &&
    posterUrl !== "" && posterUrl !== "ERR404";
}

/** Builds a stable client ID without relying on worksheet row numbers. */
function buildMovieId(country, movie) {
  const tmdbId = movie.tid || movie.tmdbId;
  if (tmdbId) return `${country}:tmdb:${tmdbId}`;
  const fallbackSource = [movie.source, movie.localTitle, movie.releaseDate]
      .map((value) => String(value || "").trim().toLowerCase())
      .join("|");
  const hash = crypto.createHash("sha256").update(fallbackSource).digest("hex").slice(0, 16);
  return `${country}:${movie.source || "unknown"}:${hash}`;
}

/** Builds the compact schema downloaded by clients from Storage. */
function buildStorageMovie(movie) {
  return {
    id: movie.id || "",
    tid: movie.tid || movie.tmdbId || "",
    posterUrl: movie.posterUrl || "",
    trailerUrl: movie.trailerUrl || "",
    runtime: movie.runtime || "",
    releaseDate: movie.releaseDate || "",
    credits: movie.credits || {cast: [], crew: []},
    originSource: movie.originSource || {},
    translations: movie.translations || {},
    metadata: movie.metadata || buildMovieMetadata(movie),
  };
}

/** Keeps only person fields required by the client and external TMDB links. */
function compactCredits(credits) {
  const source = credits || {};
  const cast = Array.isArray(source.cast) ? source.cast.map((person) => ({
    id: person && person.id || "",
    name: person && person.name || "",
    character: person && person.character || "",
  })).filter((person) => person.id && person.name) : [];
  const crew = Array.isArray(source.crew) ? source.crew.map((person) => ({
    id: person && person.id || "",
    name: person && person.name || "",
    job: person && person.job || "",
  })).filter((person) => person.id && person.name) : [];
  return {cast, crew};
}

/** Returns a stable key used to preserve credits across manual Sheet syncs. */
function movieLookupKey(movie) {
  return String(movie.id || movie.tid || movie.tmdbId || "");
}

/** Reads existing Storage credits so Sheet-only edits do not discard person IDs. */
async function readExistingCredits(fileName) {
  try {
    const [buffer] = await admin.storage().bucket().file(fileName).download();
    const data = JSON.parse(buffer.toString("utf8"));
    return new Map((data.movies || []).map((movie) =>
      [movieLookupKey(movie), compactCredits(movie.credits)]).filter(([key]) => key));
  } catch (error) {
    if (error.code !== 404) console.warn(`Could not preserve credits from ${fileName}:`, error.message);
    return new Map();
  }
}

/** Reads finalized rows for a country/category directly from Google Sheets. */
async function readFinalizedSheet(normalizedCountry) {
  if (normalizedCountry === "special") return await readSpecialDataSheet();
  if (normalizedCountry === "box_office" || normalizedCountry === "box_office_kr") {
    const sheetName = normalizedCountry === "box_office" ? BOX_OFFICE_USA_SHEET : BOX_OFFICE_KR_SHEET;
    return await readBoxOfficeSheet(sheetName);
  }
  if (hasCountrySheet(normalizedCountry)) return await readCountrySheet(normalizedCountry);
  throw new Error(`No finalized worksheet configured for ${normalizedCountry}.`);
}

/** Returns true when every non-empty source field has every translation result. */
function areTranslationsComplete(movies) {
  return movies.every((movie) => {
    const source = movie.originSource || {};
    const translations = Object.values(movie.translations || {});
    if (translations.length === 0) return false;
    const requiredFields = ["title", "overview", "country", "credits"];
    if (source.concept) requiredFields.push("concept");
    return translations.every((translation) => requiredFields.every((field) =>
      !source[field] || String(translation[field] || "").trim() !== ""));
  });
}

/** Waits for GOOGLETRANSLATE formula results before publishing Storage JSON. */
async function readFinalizedSheetAfterTranslations(normalizedCountry) {
  for (let attempt = 1; attempt <= TRANSLATION_POLL_ATTEMPTS; attempt++) {
    const movies = await readFinalizedSheet(normalizedCountry);
    if (areTranslationsComplete(movies)) return movies;
    if (attempt < TRANSLATION_POLL_ATTEMPTS) {
      console.log(`Translations for ${normalizedCountry} are incomplete (${attempt}/${TRANSLATION_POLL_ATTEMPTS}); retrying in ${TRANSLATION_POLL_INTERVAL_MS / 1000}s.`);
      await new Promise((resolve) => setTimeout(resolve, TRANSLATION_POLL_INTERVAL_MS));
    }
  }
  const waitSeconds = (TRANSLATION_POLL_ATTEMPTS - 1) * TRANSLATION_POLL_INTERVAL_MS / 1000;
  throw new Error(`Translations for ${normalizedCountry} did not finish within ${waitSeconds} seconds; existing Storage JSON was preserved.`);
}

/** Publishes already finalized Sheet rows to Firebase Storage. */
async function publishSheetMovies(normalizedCountry, processedMovies = []) {
  const timestamp = new Date().toISOString();
  const sheetMovies = (await readFinalizedSheetAfterTranslations(normalizedCountry)).filter(isPublishableMovie);
  const fileName = `movies_${normalizedCountry}.json`;
  const existingCredits = await readExistingCredits(fileName);
  const processedCredits = new Map(processedMovies.map((movie) =>
    [movieLookupKey(movie), compactCredits(movie.credits)]).filter(([key]) => key));
  const storageMovies = sheetMovies.map((movie) => {
    const key = movieLookupKey(movie);
    return buildStorageMovie({
      ...movie,
      credits: processedCredits.get(key) || existingCredits.get(key) || {cast: [], crew: []},
    });
  });
  const dataToSave = {
    schemaVersion: 2,
    timestamp,
    country: normalizedCountry,
    movies: storageMovies,
  };

  const bucket = admin.storage().bucket();
  await bucket.file(fileName).save(JSON.stringify(dataToSave), {
    metadata: {
      contentType: "application/json",
      cacheControl: "public, max-age=3600, must-revalidate",
    },
  });
  console.log(`Published ${storageMovies.length} finalized Sheet movies to ${fileName} at ${timestamp}.`);
  return dataToSave;
}

/** Writes source data to Sheets, reads formula results, then publishes JSON. */
async function publishMovies(country, movies) {
  const normalizedCountry = BOX_OFFICE_USA_COUNTRIES.has(country) ? "box_office" :
    BOX_OFFICE_KR_COUNTRIES.has(country) ? "box_office_kr" : country;
  const publishableMovies = movies.filter(isPublishableMovie).map((movie) => ({
    ...movie,
    id: movie.id || buildMovieId(normalizedCountry, movie),
  }));
  const sheetInputMovies = publishableMovies.map((movie) => ({
    ...movie,
    originSource: buildOriginSource(movie),
  }));

  if (normalizedCountry === "special") {
    await replaceSpecialDataSheet(sheetInputMovies);
  } else if (normalizedCountry === "box_office" || normalizedCountry === "box_office_kr") {
    const sheetName = normalizedCountry === "box_office" ? BOX_OFFICE_USA_SHEET : BOX_OFFICE_KR_SHEET;
    await replaceBoxOfficeSheet(sheetName, sheetInputMovies);
  } else if (hasCountrySheet(normalizedCountry)) {
    await replaceCountrySheet(normalizedCountry, sheetInputMovies);
  } else {
    throw new Error(`Sheet publishing is not configured for ${normalizedCountry}.`);
  }
  return await publishSheetMovies(normalizedCountry, sheetInputMovies);
}

module.exports = {
  areTranslationsComplete,
  buildMovieId,
  buildStorageMovie,
  compactCredits,
  isPublishableMovie,
  publishMovies,
  publishSheetMovies,
};
