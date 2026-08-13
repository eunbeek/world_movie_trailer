/* eslint-disable max-len */
const {readSpecialSourceSheet} = require("../../services/movie_sheet");

/**
 * Fetches special movie data by director.
 * @return {Promise<Array>}
 * A promise that resolves to a list of movies from the Google Sheet.
 */
async function fetchMovieInSpecialSection() {
  try {
    return await readSpecialSourceSheet();
  } catch (error) {
    console.error("Error fetching movie data:", error);
    throw error;
  }
}


module.exports = {
  fetchMovieInSpecialSection,
};
