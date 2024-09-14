/* eslint-disable max-len */
const axios = require("axios");

/**
 * Fetches special movie data by director.
 * @return {Promise<Array>}
 * A promise that resolves to a list of movies from the Google Sheet.
 */
async function fetchMovieInSpecialSection() {
  const movies = [];
  const currentDate = new Date();
  const currentPeriod = `${currentDate.getFullYear()}-${String(currentDate.getMonth() + 1).padStart(2, "0")}`;

  try {
    const response = await axios.get(
        "https://docs.google.com/spreadsheets/d/1GAVRJu8eY9ZArRX7pBrb427Ps6NCHiOsBhbQ6QV6ce4/export?format=tsv&gid=1234673196&range=A1:R",
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

          if (row["Period"] !== currentPeriod) {
            continue;
          }
          console.log(row["Period"]);
          const movie = {
            localTitle: row["Movie"] || "",
            posterUrl: row["Poster"] || "",
            country: row["Nationality"] || "",
            source: row["English_Name"] || "",
            trailerUrl: row["Trailer"] || "",
            tid: row["Tid"] || "",
            special: row["Title"] || "",
            year: row["Year"] || "",
            NameKR: row["Korean_Name"] || "",
            NameJP: row["Japanese_Name"] || "",
            NameCH: row["SimplifiedC_Name"] || "",
            NameTW: row["TraditionalC_Name"] || "",
            NameFR: row["French_Name"] || "",
            NameDE: row["German_Name"] || "",
            NameES: row["Spanish_Name"] || "",
            NameHI: row["Hindi_Name"] || "",
            NameTH: row["Thai_Name"] || "",
            batch: false,
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
