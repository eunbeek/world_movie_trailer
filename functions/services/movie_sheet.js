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
const CREDITS_DELIMITER = " ||| ";
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

const SPECIAL_SOURCE_TITLE_COLUMNS = {
  ko: 15,
  en: 16,
  ja: 17,
  cn: 18,
  tw: 19,
  fr: 20,
  de: 21,
  es: 22,
  in: 23,
  th: 24,
};

const SPECIAL_SOURCE_CONCEPT_COLUMNS = {
  ko: 25,
  en: 26,
  ja: 27,
  cn: 28,
  tw: 29,
  fr: 30,
  de: 31,
  es: 32,
  in: 33,
  th: 34,
};

const SPECIAL_SOURCE_CREDIT_COLUMNS = {
  ko: 5,
  en: 6,
  ja: 7,
  cn: 8,
  tw: 9,
  fr: 10,
  de: 11,
  es: 12,
  in: 13,
  th: 14,
};

const SPECIAL_DATA_TITLE_COLUMNS = {
  ko: "N",
  en: "R",
  ja: "V",
  cn: "Z",
  tw: "AD",
  fr: "AH",
  es: "AL",
  de: "AP",
  in: "AT",
  th: "AX",
};

const SPECIAL_DATA_CONCEPT_COLUMNS = {
  ko: "M",
  en: "Q",
  ja: "U",
  cn: "Y",
  tw: "AC",
  fr: "AG",
  es: "AK",
  de: "AO",
  in: "AS",
  th: "AW",
};

const SPECIAL_DATA_CREDIT_COLUMNS = {
  ko: "P",
  en: "T",
  ja: "X",
  cn: "AB",
  tw: "AF",
  fr: "AJ",
  es: "AN",
  de: "AR",
  in: "AV",
  th: "AZ",
};

const COUNTRY_DISPLAY_LOCALES = {
  ko: "ko",
  en: "en",
  ja: "ja",
  cn: "zh-CN",
  tw: "zh-TW",
  fr: "fr",
  de: "de",
  es: "es",
  in: "hi",
  th: "th",
};

const COUNTRY_NAME_TO_CODES = {
  "american": ["US"],
  "argentina": ["AR"],
  "austria": ["AT"],
  "belgium": ["BE"],
  "benin": ["BJ"],
  "brazil": ["BR"],
  "british": ["GB"],
  "british-american": ["GB", "US"],
  "canada": ["CA"],
  "chile": ["CL"],
  "china": ["CN"],
  "cuba": ["CU"],
  "denmark": ["DK"],
  "france": ["FR"],
  "germany": ["DE"],
  "hong kong": ["HK"],
  "hungary": ["HU"],
  "india": ["IN"],
  "iran": ["IR"],
  "ireland": ["IE"],
  "israel": ["IL"],
  "italy": ["IT"],
  "japan": ["JP"],
  "korea": ["KR"],
  "kosovo": ["XK"],
  "mexico": ["MX"],
  "new zealand": ["NZ"],
  "norway": ["NO"],
  "palestine": ["PS"],
  "philippines": ["PH"],
  "poland": ["PL"],
  "portugal": ["PT"],
  "romania": ["RO"],
  "senegal": ["SN"],
  "south korea": ["KR"],
  "spain": ["ES"],
  "sweden": ["SE"],
  "switzerland": ["CH"],
  "turkey": ["TR"],
  "uk": ["GB"],
  "us": ["US"],
  "usa": ["US"],
  "venezuela": ["VE"],
};

/** Converts free-form Special country values to localized country names. */
function localizeSpecialCountry(value, language) {
  const raw = String(value || "").trim();
  if (!raw) return "";
  const locale = COUNTRY_DISPLAY_LOCALES[language] || "en";
  const displayNames = new Intl.DisplayNames([locale], {type: "region"});
  const tokens = raw.split(/\s*(?:&|\/|,)\s*/).filter(Boolean);
  const localized = tokens.flatMap((token) => {
    const normalized = token.trim().toLowerCase().replace(/\./g, "");
    const codes = COUNTRY_NAME_TO_CODES[normalized];
    if (!codes) return [token.trim()];
    return codes.map((code) => displayNames.of(code) || token.trim());
  });
  return [...new Set(localized)].join(" · ");
}

/** Parses one row from the planner-managed multilingual SPECIAL_SOURCE sheet. */
function parseSpecialSourceRow(row) {
  const translations = Object.fromEntries(Object.entries(SPECIAL_SOURCE_TITLE_COLUMNS)
      .map(([language, titleIndex]) => [language, {
        title: row[titleIndex] || "",
        concept: row[SPECIAL_SOURCE_CONCEPT_COLUMNS[language]] || "",
        credits: row[SPECIAL_SOURCE_CREDIT_COLUMNS[language]] || "",
      }]));
  const englishTitle = translations.en.title || translations.ko.title ||
    Object.values(translations).map((entry) => entry.title).find(Boolean) || "";
  const englishConcept = translations.en.concept || translations.ko.concept ||
    Object.values(translations).map((entry) => entry.concept).find(Boolean) || "";
  const englishCredits = translations.en.credits || translations.ko.credits ||
    Object.values(translations).map((entry) => entry.credits).find(Boolean) || "";
  const country = String(row[4] || "").trim();
  return {
    tid: String(row[0] || ""),
    period: Number.parseInt(row[1], 10) || 0,
    trailerUrl: row[2] || "",
    year: String(row[3] || ""),
    country,
    special: englishConcept,
    source: englishCredits,
    localTitle: englishTitle,
    sourceType: "tmdb",
    translations,
    originSource: {
      concept: englishConcept,
      title: englishTitle,
      overview: "",
      country,
      credits: englishCredits,
    },
    batch: false,
  };
}

/** Builds updates that copy planner titles into each SPECIAL_DATA Title column. */
function buildSpecialTitleUpdates(movies, lastRow) {
  return Object.entries(SPECIAL_DATA_TITLE_COLUMNS).map(([language, column]) => ({
    range: `'${SPECIAL_DATA_SHEET}'!${column}4:${column}${lastRow}`,
    values: movies.map((movie) => [
      movie.translations && movie.translations[language] &&
        movie.translations[language].title || "",
    ]),
  }));
}

/** Builds updates that copy planner concepts into each SPECIAL_DATA Concept column. */
function buildSpecialConceptUpdates(movies, lastRow) {
  return Object.entries(SPECIAL_DATA_CONCEPT_COLUMNS).map(([language, column]) => ({
    range: `'${SPECIAL_DATA_SHEET}'!${column}4:${column}${lastRow}`,
    values: movies.map((movie) => [
      movie.translations && movie.translations[language] &&
        movie.translations[language].concept || "",
    ]),
  }));
}

/** Builds updates that copy planner credits into each SPECIAL_DATA Credits column. */
function buildSpecialCreditUpdates(movies, lastRow) {
  return Object.entries(SPECIAL_DATA_CREDIT_COLUMNS).map(([language, column]) => ({
    range: `'${SPECIAL_DATA_SHEET}'!${column}4:${column}${lastRow}`,
    values: movies.map((movie) => [
      movie.translations && movie.translations[language] &&
        movie.translations[language].credits || "",
    ]),
  }));
}

/** Converts TMDB credits into the source string stored in the worksheet. */
function flattenCredits(credits) {
  if (!credits) return "";
  if (typeof credits === "string") return credits;

  const cast = Array.isArray(credits.cast) ? credits.cast : [];
  const crew = Array.isArray(credits.crew) ? credits.crew : [];
  const seen = new Set();
  return [...cast, ...crew]
      .filter((person) => {
        if (!person) return false;
        const id = typeof person === "object" && person.id;
        const name = typeof person === "string" ? person : person.name;
        const key = id ? `id:${id}` : `name:${String(name || "").trim().toLowerCase()}`;
        if (!name || seen.has(key)) return false;
        seen.add(key);
        return true;
      })
      .map((person) => typeof person === "string" ? person : person.name)
      .join(CREDITS_DELIMITER);
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
    range: `'${SPECIAL_SOURCE_SHEET}'!A2:AI`,
  });

  return (response.data.values || [])
      .filter((row) => row[0] && row.slice(15, 25).some(Boolean))
      .map(parseSpecialSourceRow);
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

/** Converts Special translation columns: concept, title, overview, credits. */
function readSpecialTranslations(row, startOffset) {
  const translations = {};
  TRANSLATION_LANGUAGES.forEach((language, index) => {
    const offset = startOffset + index * 4;
    translations[language.key] = {
      concept: row[offset] || "",
      title: row[offset + 1] || "",
      overview: row[offset + 2] || "",
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

/** Replaces SPECIAL_DATA inputs while preserving translation formulas M:AZ. */
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
    range: `'${SPECIAL_DATA_SHEET}'!A4:L${lastRow}`,
    valueInputOption: "RAW",
    requestBody: {values},
  });
  await sheets.spreadsheets.values.batchUpdate({
    spreadsheetId,
    requestBody: {
      valueInputOption: "RAW",
      data: [
        ...buildSpecialTitleUpdates(movies, lastRow),
        ...buildSpecialConceptUpdates(movies, lastRow),
        ...buildSpecialCreditUpdates(movies, lastRow),
      ],
    },
  });
  await sheets.spreadsheets.values.clear({
    spreadsheetId,
    range: `'${SPECIAL_DATA_SHEET}'!A${lastRow + 1}:L`,
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
    range: `'${SPECIAL_DATA_SHEET}'!A4:AZ`,
  });
  const sourceMovies = await readSpecialSourceSheet();
  const sourceByKey = new Map(sourceMovies.map((movie) =>
    [`${movie.period}:${movie.tid}`, movie]));
  return (response.data.values || [])
      .filter((row) => row[0] && row[4] && row[5])
      .map((row) => {
        const source = sourceByKey.get(`${row[2]}:${row[1]}`);
        const sourceOrigin = source && source.originSource || {};
        const translations = readSpecialTranslations(row, 12);
        TRANSLATION_LANGUAGES.forEach(({key}) => {
          const sourceTitle = source && source.translations &&
            source.translations[key] && source.translations[key].title || "";
          const sourceConcept = source && source.translations &&
            source.translations[key] && source.translations[key].concept || "";
          const sourceCredits = source && source.translations &&
            source.translations[key] && source.translations[key].credits || "";
          translations[key] = {
            ...translations[key],
            title: sourceTitle || translations[key].title || "",
            concept: sourceConcept || translations[key].concept || "",
            credits: sourceCredits || translations[key].credits || "",
            country: localizeSpecialCountry(sourceOrigin.country, key),
          };
        });
        return {
          id: row[0] || "",
          tid: row[1] || "",
          posterUrl: row[4] || "",
          trailerUrl: row[5] || "",
          runtime: row[6] || "",
          releaseDate: "",
          originSource: {
            concept: sourceOrigin.concept || row[8] || "",
            title: sourceOrigin.title || row[9] || "",
            overview: row[10] || "",
            country: sourceOrigin.country || "",
            credits: sourceOrigin.credits || row[11] || "",
          },
          translations,
          credits: {cast: [], crew: []},
          metadata: {
            period: row[2] || "",
            sourceType: row[3] || "",
            year: row[7] || "",
          },
        };
      });
}

module.exports = {
  BOX_OFFICE_KR_SHEET,
  BOX_OFFICE_USA_SHEET,
  COUNTRY_SHEETS,
  buildOriginSource,
  buildBoxOfficeUsaRow,
  buildSpecialDataRow,
  buildSpecialConceptUpdates,
  buildSpecialCreditUpdates,
  buildSpecialTitleUpdates,
  buildMovieMetadata,
  localizeSpecialCountry,
  parseSpecialSourceRow,
  buildSheetHeaders,
  buildSheetRow,
  CREDITS_DELIMITER,
  hasCountrySheet,
  readCountrySheet,
  readBoxOfficeSheet,
  readSpecialDataSheet,
  readSpecialSourceSheet,
  replaceBoxOfficeSheet,
  replaceCountrySheet,
  replaceSpecialDataSheet,
};
