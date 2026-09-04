/* eslint-disable max-len */
const {google} = require("googleapis");

const DEFAULT_SPREADSHEET_ID = "14HLR5Vans2EGj9X4rGhLvZ_YQx5Or9y_pKkcmfkxhmQ";
const QUOTES_SOURCE_SHEET = "Quotes_SOURCE";

const QUOTE_LANGUAGE_COLUMNS = {
  en: [1, 2],
  ko: [3, 4],
  ja: [5, 6],
  zh: [7, 8],
  tw: [9, 10],
  fr: [11, 12],
  de: [13, 14],
  es: [15, 16],
  hi: [17, 18],
  th: [19, 20],
};

/**
 * Parses one row from the multilingual Quotes_SOURCE worksheet.
 * @param {Array} row Source worksheet row.
 * @param {string} timestamp Fetch timestamp.
 * @return {Object} Quote ready for Storage publication.
 */
function parseQuoteSourceRow(row, timestamp) {
  const translations = Object.fromEntries(Object.entries(QUOTE_LANGUAGE_COLUMNS)
      .map(([language, columns]) => [language, {
        quote: row[columns[0]] || "",
        movie: row[columns[1]] || "",
      }]));
  return {
    quoteKey: String(row[0]),
    quoteEN: translations.en.quote,
    movieEN: translations.en.movie,
    quoteKR: translations.ko.quote,
    movieKR: translations.ko.movie,
    quoteJP: translations.ja.quote,
    movieJP: translations.ja.movie,
    translations,
    timestamp,
  };
}

/**
 * Reads quotes from the WMT_RESOURCE spreadsheet.
 * The Function service account must have viewer access to the spreadsheet.
 * @return {Promise<Array>} Quotes ready to publish to Storage.
 */
async function fetchQuotesInSpecialSection() {
  const spreadsheetId = process.env.MOVIE_SPREADSHEET_ID || DEFAULT_SPREADSHEET_ID;
  const auth = new google.auth.GoogleAuth({
    scopes: ["https://www.googleapis.com/auth/spreadsheets.readonly"],
  });
  const sheets = google.sheets({version: "v4", auth});
  const response = await sheets.spreadsheets.values.get({
    spreadsheetId,
    range: `'${QUOTES_SOURCE_SHEET}'!A2:U`,
  });
  const timestamp = new Date().toISOString();

  return (response.data.values || [])
      .filter((row) => row[0] && row[1] && row[2])
      .map((row) => parseQuoteSourceRow(row, timestamp));
}

module.exports = {
  fetchQuotesInSpecialSection,
  parseQuoteSourceRow,
};
