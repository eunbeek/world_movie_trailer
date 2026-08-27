/* eslint-disable max-len, valid-jsdoc */
const {google} = require("googleapis");

const TRANSLATION_LANGUAGES = [
  {key: "ko", locale: "ko-KR", sheetLabel: "KO"},
  {key: "en", locale: "en-US", sheetLabel: "EN"},
  {key: "ja", locale: "ja-JP", sheetLabel: "JA"},
  {key: "cn", locale: "zh-CN", sheetLabel: "CN"},
  {key: "tw", locale: "zh-TW", sheetLabel: "TW"},
  {key: "fr", locale: "fr-FR", sheetLabel: "FR"},
  {key: "es", locale: "es-ES", sheetLabel: "ES"},
  {key: "de", locale: "de-DE", sheetLabel: "DE"},
  {key: "in", locale: "hi-IN", sheetLabel: "IN"},
  {key: "th", locale: "th-TH", sheetLabel: "TH"},
];

const DEFAULT_SPREADSHEET_ID = "14HLR5Vans2EGj9X4rGhLvZ_YQx5Or9y_pKkcmfkxhmQ";
const BOX_OFFICE_USA_SHEET = "BOX_OFFICE_USA_DATA";
const BOX_OFFICE_KR_SHEET = "BOX_OFFICE_KR_DATA";
const SPECIAL_SOURCE_SHEET = "SPECIAL_SOURCE";
const SPECIAL_DATA_SHEET = "SPECIAL_DATA";
const COUNTRY_SHEETS = {
  kr: "KOREA_DATA",
  jp: "JAPAN_DATA",
  ca: "CANADA_DATA",
  tw: "TAIWAN_DATA",
  fr: "FRANCE_DATA",
  de: "GERMANY_DATA",
  us: "USA_DATA",
  th: "THAI_DATA",
  au: "AUST_DATA",
  es: "SPAIN_DATA",
  in: "INDIA_DATA",
  cn: "CHINA_DATA",
};

/** Converts TMDB credits into the source string stored in the worksheet. */
function flattenCredits(credits) {
  if (!credits) return "";
  if (typeof credits === "string") return credits;

  const cast = Array.isArray(credits.cast) ? credits.cast : [];
  const crew = Array.isArray(credits.crew) ? credits.crew : [];
  return [...cast, ...crew]
      .map((person) => typeof person === "string" ? person : person && person.name)
      .filter(Boolean)
      .filter((person, index, people) => people.indexOf(person) === index)
      .join(", ");
}

/** Returns the first valid ISO 3166-1 alpha-2 country code on a movie. */
function countryCodeFromMovie(movie) {
  const rawCountry = movie.originCountry || movie.countryCode || movie.country || "";
  const candidate = Array.isArray(rawCountry) ? rawCountry[0] : rawCountry;
  const normalized = String(candidate).trim().toUpperCase();
  return /^[A-Z]{2}$/.test(normalized) ? normalized : "";
}

/** Builds the source values consumed by the worksheet translation formulas. */
function buildOriginSource(movie) {
  const existing = movie.originSource || {};
  return {
    concept: existing.concept || movie.special || "",
    title: movie.localTitle || existing.title || movie.title || "",
    overview: movie.spec || existing.overview || movie.overview || "",
    country: existing.country || countryCodeFromMovie(movie),
    credits: existing.credits || flattenCredits(movie.credits),
  };
}

/** Builds the three header rows used by every country worksheet. */
function buildSheetHeaders() {
  const groups = ["META DATA", "", "", "", "", "", "", "ORIGIN SOURCE", "", "", ""];
  const locales = ["", "", "", "", "", "", "", "AUTO", "AUTO", "ISO", "AUTO"];
  const fields = [
    "ID", "TID", "From", "Movie Poster URL", "Trailer URL", "Runtime", "Release Date",
    "Title", "Overview", "Country", "Credits",
  ];

  TRANSLATION_LANGUAGES.forEach((language) => {
    groups.push(language.sheetLabel, "", "", "");
    locales.push(language.locale, language.locale, language.locale, language.locale);
    fields.push("Title", "Overview", "Country", "Credits");
  });
  return [groups, locales, fields];
}

/** Keeps non-localized movie values together for the client JSON. */
function buildMovieMetadata(movie) {
  const excludedKeys = new Set([
    "id", "batch", "originSource", "translations", "metadata",
    "tid", "tmdbId", "posterUrl", "trailerUrl", "runtime", "releaseDate",
    "localTitle", "title", "spec", "overview", "country", "countryCode", "originCountry", "credits",
    "nameKR", "nameJP", "nameCH", "nameTW", "nameFR", "nameDE", "nameES", "nameHI", "nameTH",
  ]);
  return Object.keys(movie).reduce((metadata, key) => {
    if (!excludedKeys.has(key)) metadata[key] = movie[key];
    return metadata;
  }, {});
}

/** Converts one translated movie to the 52-column worksheet schema. */
function buildSheetRow(movie) {
  const origin = movie.originSource || {};
  const row = [
    movie.id || "",
    movie.tid || "",
    movie.source || "",
    movie.posterUrl || "",
    movie.trailerUrl || "",
    movie.runtime || "",
    movie.releaseDate || "",
    origin.title || "",
    origin.overview || "",
    origin.country || "",
    origin.credits || "",
  ];

  TRANSLATION_LANGUAGES.forEach((language) => {
    const translation = movie.translations && movie.translations[language.key] || {};
    row.push(
        translation.title || "",
        translation.overview || "",
        translation.country || "",
        translation.credits || "",
    );
  });

  return {row};
}

/** Converts a movie to the BOX_OFFICE_USA_DATA input schema. */
function buildBoxOfficeUsaRow(movie) {
  const origin = movie.originSource || {};
  return [
    movie.id || "",
    movie.tid || "",
    movie.source || "",
    movie.posterUrl || "",
    movie.trailerUrl || "",
    movie.runtime || "",
    movie.releaseDate || "",
    movie.rank || "",
    movie.lastRank || "",
    movie.gross || "",
    movie.percentChange || "",
    movie.theaters || "",
    movie.theaterChange || "",
    movie.perTheaterGross || "",
    movie.totalGross || "",
    movie.weeks || "",
    movie.distributor || "",
    movie.isNewThisWeek === true ? "TRUE" : "FALSE",
    movie.weekStartDate || "",
    movie.weekEndDate || "",
    origin.title || "",
    origin.overview || "",
    origin.country || "",
    origin.credits || "",
  ];
}

/** Converts a processed Special movie to SPECIAL_DATA source columns A:M. */
function buildSpecialDataRow(movie) {
  const origin = movie.originSource || {};
  return [
    movie.id || "",
    movie.tid || "",
    movie.period || "",
    movie.sourceType || "tmdb",
    movie.posterUrl || "",
    movie.trailerUrl || "",
    movie.runtime || "",
    movie.year || "",
    origin.concept || movie.special || "",
    origin.title || movie.localTitle || "",
    origin.overview || movie.spec || "",
    origin.country || movie.country || "",
    origin.credits || movie.source || "",
  ];
}

/** Reads the planner-managed SPECIAL_SOURCE worksheet without modifying it. */
async function readSpecialSourceSheet() {
  const spreadsheetId = process.env.MOVIE_SPREADSHEET_ID || DEFAULT_SPREADSHEET_ID;
  const auth = new google.auth.GoogleAuth({
    scopes: ["https://www.googleapis.com/auth/spreadsheets.readonly"],
  });
  const sheets = google.sheets({version: "v4", auth});
  const response = await sheets.spreadsheets.values.get({
    spreadsheetId,
    range: `'${SPECIAL_SOURCE_SHEET}'!A2:H`,
  });

  return (response.data.values || [])
      .filter((row) => row[0] && row[6])
      .map((row) => ({
        tid: String(row[0]),
        period: Number.parseInt(row[1], 10) || 0,
        trailerUrl: row[2] || "",
        year: String(row[3] || ""),
        special: row[4] || "",
        source: row[5] || "",
        localTitle: row[6] || "",
        country: row[7] || "",
        sourceType: "tmdb",
        originSource: {
          concept: row[4] || "",
          title: row[6] || "",
          overview: "",
          country: row[7] || "",
          credits: row[5] || "",
        },
        batch: false,
      }));
}

/** Returns whether a finalized country worksheet exists. */
function hasCountrySheet(country) {
  return Boolean(COUNTRY_SHEETS[country]);
}

/** Converts the translation columns in a worksheet row to JSON. */
function readTranslations(row, startOffset, fieldCount = 4) {
  const translations = {};
  TRANSLATION_LANGUAGES.forEach((language, index) => {
    const offset = startOffset + index * fieldCount;
    translations[language.key] = fieldCount === 5 ? {
      concept: row[offset] || "",
      title: row[offset + 1] || "",
      overview: row[offset + 2] || "",
      country: row[offset + 3] || "",
      credits: row[offset + 4] || "",
    } : {
      title: row[offset] || "",
      overview: row[offset + 1] || "",
      country: row[offset + 2] || "",
      credits: row[offset + 3] || "",
    };
  });
  return translations;
}

/** Reads complete country rows. The worksheet is the Storage source of truth. */
async function readCountrySheet(country) {
  const sheetName = COUNTRY_SHEETS[country];
  if (!sheetName) return [];

  const spreadsheetId = process.env.MOVIE_SPREADSHEET_ID || DEFAULT_SPREADSHEET_ID;
  const auth = new google.auth.GoogleAuth({
    scopes: ["https://www.googleapis.com/auth/spreadsheets"],
  });
  const sheets = google.sheets({version: "v4", auth});
  const response = await sheets.spreadsheets.values.get({
    spreadsheetId,
    range: `'${sheetName}'!A4:AY`,
  });
  return (response.data.values || [])
      .filter((row) => row[0] && row[3] && row[4])
      .map((row) => ({
        id: row[0] || "",
        tid: row[1] || "",
        posterUrl: row[3] || "",
        trailerUrl: row[4] || "",
        runtime: row[5] || "",
        releaseDate: row[6] || "",
        originSource: {
          title: row[7] || "",
          overview: row[8] || "",
          country: row[9] || "",
          credits: row[10] || "",
        },
        translations: readTranslations(row, 11),
        credits: {cast: [], crew: []},
        metadata: {source: row[2] || ""},
      }));
}

/** Replaces only input columns A:K, preserving translation formulas in L:AY. */
async function replaceCountrySheet(country, movies) {
  const sheetName = COUNTRY_SHEETS[country];
  if (!sheetName) throw new Error(`No Google Sheet configured for country: ${country}`);

  const spreadsheetId = process.env.MOVIE_SPREADSHEET_ID || DEFAULT_SPREADSHEET_ID;
  const auth = new google.auth.GoogleAuth({
    scopes: ["https://www.googleapis.com/auth/spreadsheets"],
  });
  const sheets = google.sheets({version: "v4", auth});
  const values = movies.map((movie) => buildSheetRow(movie).row.slice(0, 11));

  await sheets.spreadsheets.values.update({
    spreadsheetId,
    range: `'${sheetName}'!A4:K${movies.length + 3}`,
    valueInputOption: "RAW",
    requestBody: {values},
  });
  await sheets.spreadsheets.values.clear({
    spreadsheetId,
    range: `'${sheetName}'!A${movies.length + 4}:K`,
  });

  console.log(`Google Sheet ${sheetName} input columns replaced with ${movies.length} movies.`);
}

/** Replaces Box Office inputs while preserving translation formulas Y:BL. */
async function replaceBoxOfficeSheet(sheetName, movies) {
  const spreadsheetId = process.env.MOVIE_SPREADSHEET_ID || DEFAULT_SPREADSHEET_ID;
  const auth = new google.auth.GoogleAuth({
    scopes: ["https://www.googleapis.com/auth/spreadsheets"],
  });
  const sheets = google.sheets({version: "v4", auth});
  const rows = movies.map(buildBoxOfficeUsaRow);
  const lastRow = movies.length + 3;

  await sheets.spreadsheets.values.update({
    spreadsheetId,
    range: `'${sheetName}'!A4:X${lastRow}`,
    valueInputOption: "RAW",
    requestBody: {values: rows},
  });
  await sheets.spreadsheets.values.clear({
    spreadsheetId,
    range: `'${sheetName}'!A${lastRow + 1}:X`,
  });
  console.log(`Google Sheet ${sheetName} inputs replaced with ${movies.length} movies.`);
}

/** Reads complete Box Office rows from the worksheet. */
async function readBoxOfficeSheet(sheetName) {
  const spreadsheetId = process.env.MOVIE_SPREADSHEET_ID || DEFAULT_SPREADSHEET_ID;
  const auth = new google.auth.GoogleAuth({
    scopes: ["https://www.googleapis.com/auth/spreadsheets"],
  });
  const sheets = google.sheets({version: "v4", auth});
  const response = await sheets.spreadsheets.values.get({
    spreadsheetId,
    range: `'${sheetName}'!A4:BL`,
  });
  return (response.data.values || [])
      .filter((row) => row[0] && row[3] && row[4])
      .map((row) => ({
        id: row[0] || "",
        tid: row[1] || "",
        posterUrl: row[3] || "",
        trailerUrl: row[4] || "",
        runtime: row[5] || "",
        releaseDate: row[6] || "",
        originSource: {
          title: row[20] || "",
          overview: row[21] || "",
          country: row[22] || "",
          credits: row[23] || "",
        },
        translations: readTranslations(row, 24),
        credits: {cast: [], crew: []},
        metadata: {
          source: row[2] || "",
          rank: row[7] || "",
          lastRank: row[8] || "",
          gross: row[9] || "",
          percentChange: row[10] || "",
          theaters: row[11] || "",
          theaterChange: row[12] || "",
          perTheaterGross: row[13] || "",
          totalGross: row[14] || "",
          weeks: row[15] || "",
          distributor: row[16] || "",
          isNewThisWeek: String(row[17] || "").toUpperCase() === "TRUE",
          weekStartDate: row[18] || "",
          weekEndDate: row[19] || "",
        },
      }));
}

/** Replaces SPECIAL_DATA inputs while preserving translation formulas N:BK. */
async function replaceSpecialDataSheet(movies) {
  const spreadsheetId = process.env.MOVIE_SPREADSHEET_ID || DEFAULT_SPREADSHEET_ID;
  const auth = new google.auth.GoogleAuth({
    scopes: ["https://www.googleapis.com/auth/spreadsheets"],
  });
  const sheets = google.sheets({version: "v4", auth});
  const values = movies.map(buildSpecialDataRow);
  const lastRow = movies.length + 3;

  await sheets.spreadsheets.values.update({
    spreadsheetId,
    range: `'${SPECIAL_DATA_SHEET}'!A4:M${lastRow}`,
    valueInputOption: "RAW",
    requestBody: {values},
  });
  await sheets.spreadsheets.values.clear({
    spreadsheetId,
    range: `'${SPECIAL_DATA_SHEET}'!A${lastRow + 1}:M`,
  });
  console.log(`Google Sheet ${SPECIAL_DATA_SHEET} inputs replaced with ${movies.length} movies.`);
}

/** Reads complete Special rows from the worksheet. */
async function readSpecialDataSheet() {
  const spreadsheetId = process.env.MOVIE_SPREADSHEET_ID || DEFAULT_SPREADSHEET_ID;
  const auth = new google.auth.GoogleAuth({
    scopes: ["https://www.googleapis.com/auth/spreadsheets"],
  });
  const sheets = google.sheets({version: "v4", auth});
  const response = await sheets.spreadsheets.values.get({
    spreadsheetId,
    range: `'${SPECIAL_DATA_SHEET}'!A4:BK`,
  });
  return (response.data.values || [])
      .filter((row) => row[0] && row[4] && row[5])
      .map((row) => ({
        id: row[0] || "",
        tid: row[1] || "",
        posterUrl: row[4] || "",
        trailerUrl: row[5] || "",
        runtime: row[6] || "",
        releaseDate: "",
        originSource: {
          concept: row[8] || "",
          title: row[9] || "",
          overview: row[10] || "",
          country: row[11] || "",
          credits: row[12] || "",
        },
        translations: readTranslations(row, 13, 5),
        credits: {cast: [], crew: []},
        metadata: {
          period: row[2] || "",
          sourceType: row[3] || "",
          year: row[7] || "",
        },
      }));
}

module.exports = {
  BOX_OFFICE_KR_SHEET,
  BOX_OFFICE_USA_SHEET,
  COUNTRY_SHEETS,
  buildOriginSource,
  buildBoxOfficeUsaRow,
  buildSpecialDataRow,
  buildMovieMetadata,
  buildSheetHeaders,
  buildSheetRow,
  hasCountrySheet,
  readCountrySheet,
  readBoxOfficeSheet,
  readSpecialDataSheet,
  readSpecialSourceSheet,
  replaceBoxOfficeSheet,
  replaceCountrySheet,
  replaceSpecialDataSheet,
};
