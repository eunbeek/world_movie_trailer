/* eslint-disable max-len */
const {fetchRunningMovieByCountryCode, fetchUpcomingMovieByCountryCode} = require("./tmdb");

/**
 * Fetches movie data from TMDB for the US.
 * @return {Promise<Array>}
 * A promise that resolves to a list of movies from TMDB.
 */
async function fetchMovieListFromTMDBByAU() {
  const movies = [];

  /**
   * Fetches running and upcoming movie data from TMDB for the AU.
   * The function fetches data in two batches (two pages) for both running and upcoming movies.
   * The fetched data includes the movie title, country, source, specification, release date, and TMDB ID.
   * @param {String} page - page number
   * @return {Promise<Array>} A promise that resolves to a list of movies from TMDB.
   * Each movie object contains the following properties:
   * - `localTitle` (string): The title of the movie.
   * - `country` (string): The country code, which is "au" for this function.
   * - `source` (string): The source of the data, which is "imdb" for this function.
   * - `spec` (string): The overview or specification of the movie.
   * - `releaseDate` (string): The release date of the movie in YYYY-MM-DD format.
   * - `tid` (number): The TMDB ID of the movie.
   */
  async function fetchMovies(page) {
    try {
      const responseRun = await fetchRunningMovieByCountryCode("AU", "en-AU", page);
      const responseUp = await fetchUpcomingMovieByCountryCode("AU", "en-AU", page);

      const addMovies = (response) => {
        if (response) {
          response.forEach((item) => {
            movies.push({
              localTitle: item.title,
              source: "imdb",
              spec: item.overview,
              releaseDate: item.release_date,
              tid: item.id,
              batch: false,
            });
          });
        } else {
          console.error("Failed to fetch data:", response.status);
        }
      };

      addMovies(responseRun);
      addMovies(responseUp);
    } catch (err) {
      console.error("Error fetching from IMDB:", err);
    }
  }

  // Fetch for pages 1 and 2
  await fetchMovies("1");
  await fetchMovies("2");
  await fetchMovies("3");
  await fetchMovies("4");

  return movies;
}

module.exports = {
  fetchMovieListFromTMDBByAU,
};
