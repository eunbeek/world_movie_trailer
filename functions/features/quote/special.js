/* eslint-disable max-len */
const axios = require("axios");

/**
 * Fetches special quotes data.
 * @return {Promise<Array>}
 * A promise that resolves to a list of movies from the Google Sheet.
 */
async function fetchQuotesInSpecialSection() {
  const quotes = [];

  try {
    const response = await axios.get(
        "https://docs.google.com/spreadsheets/d/1GAVRJu8eY9ZArRX7pBrb427Ps6NCHiOsBhbQ6QV6ce4/export?format=tsv&gid=42140390&range=A1:G",
    );

    if (response.status === 200) {
      const lines = response.data.split("\n");
      const headers = lines[0].split("\t").map((header) => header.trim());
      const timestamp = new Date();
      for (let i = 1; i < lines.length; i++) {
        const line = lines[i].trim();
        if (line) { // Ensure the line is not empty
          const values = line.split("\t");

          const row = {};
          headers.forEach((header, index) => {
            row[header] = values[index] || ""; // Safely assign values
          });

          const movie = {
            quoteKey: row["Quote_Key"] || "",
            quoteEN: row["Quote_EN"] || "",
            movieEN: row["Movie_EN"] || "",
            quoteKR: row["Quote_KR"] || "",
            movieKR: row["Movie_KR"] || "",
            quoteJP: row["Quote_JP"] || "",
            movieJP: row["Movie_JP"] || "",
            timestamp: timestamp,
          };

          quotes.push(movie);
        }
      }
    } else {
      console.error("Failed to load data");
    }
  } catch (error) {
    console.error("Error fetching quote data:", error);
  }

  return quotes;
}

module.exports = {
  fetchQuotesInSpecialSection,
};
