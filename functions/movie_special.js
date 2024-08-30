/* eslint-disable max-len */
const axios = require("axios");

/**
 * Fetches special movie data by director.
 * @return {Promise<Array>}
 * A promise that resolves to a list of movies from the Google Sheet.
 */
async function fetchMovieInSpecialSection() {
  const movies = [];
  try {
    const response = await axios.get(
        "https://docs.google.com/spreadsheets/d/1GAVRJu8eY9ZArRX7pBrb427Ps6NCHiOsBhbQ6QV6ce4/export?format=tsv&gid=2145613691&range=A1:H9",
    );

    if (response.status === 200) {
      const lines = response.data.split("\n");
      const headers = lines[0].split("\t").map((header) => header.trim());

      for (let i = 1; i < lines.length; i++) {
        const line = lines[i].trim();
        if (line) { // Ensure the line is not empty
          const values = line.split("\t");

          const row = {};
          headers.forEach((header, index) => {
            row[header] = values[index] || ""; // Safely assign values
          });

          const movie = {
            localTitle: row["Movie"] || "",
            posterUrl: row["Poster"] || "",
            country: row["Natinality"] || "",
            source: row["Director"] || "",
            trailerUrl: row["Trailer"] || "",
            tid: row["Tid"] || "",
            special: row["Title"] || "",
            year: row["Year"] || "",
          };

          movies.push(movie);
        }
      }
    } else {
      console.error("Failed to load data");
    }
  } catch (error) {
    console.error("Error fetching movie data:", error);
  }

  return movies;
}


module.exports = {
  fetchMovieInSpecialSection,
};
