/* eslint-disable max-len */
const {google} = require("googleapis");

const DEFAULT_SPREADSHEET_ID = "14HLR5Vans2EGj9X4rGhLvZ_YQx5Or9y_pKkcmfkxhmQ";
const QUOTES_SOURCE_SHEET = "Quotes_SOURCE";

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
    range: `'${QUOTES_SOURCE_SHEET}'!A2:G`,
  });
  const timestamp = new Date().toISOString();

  return (response.data.values || [])
      .filter((row) => row[0] && row[1] && row[2])
      .map((row) => ({
        quoteKey: String(row[0]),
        quoteEN: row[1] || "",
        movieEN: row[2] || "",
        quoteKR: row[3] || "",
        movieKR: row[4] || "",
        quoteJP: row[5] || "",
        movieJP: row[6] || "",
        timestamp,
      }));
}

module.exports = {
  fetchQuotesInSpecialSection,
};
