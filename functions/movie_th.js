/* eslint-disable max-len */
const axios = require("axios");
const cheerio = require("cheerio");

const sfcinemaUrl = "https://www.sfcinemacity.com";

/**
 * Fetches movie data from SFCinema
 * @return {Promise<Array>}
 * A promise that resolves to a list of movies from SFCinema.
 */
async function fetchMovieListFromSf() {
  const movies = [];

  try {
    const response = await axios.get(sfcinemaUrl);
    const $ = cheerio.load(response.data);

    const scriptTag = $("script")
        .filter((i, el) => $(el).html().includes("__INITIAL_STATE__"))
        .html();

    if (!scriptTag) {
      return null;
    }

    // Extract the JSON object from the script content
    const jsonString = scriptTag.match(/window\.__INITIAL_STATE__\s*=\s*(\{.*?\});/)[1];
    const initialState = JSON.parse(jsonString);

    // Access the coming_soon object
    const months = initialState.coming_soon.months;
    // Loop through each month and get the movies
    for (const [, itemByMonth] of Object.entries(months)) {
      const moviesByMonth = itemByMonth.movies;
      // Process the movies (details.movies is an object, you may need to loop through if it's an array)
      for (const [, details] of Object.entries(moviesByMonth)) {
        const movie = {
          localTitle: details.name["th"],
          posterUrl: details.image_url["port"],
          source: "sf",
          batch: false,
        };
        movies.push(movie);
      }
    }

    // Access the coming_soon object
    const boxOffice = initialState.box_office;
    // Loop through each month and get the movies
    for (const [, itemByOffice] of Object.entries(boxOffice)) {
      for (const [, details] of Object.entries(itemByOffice)) {
        if (!movies.find((m) => m.localTitle == details.name["th"])) {
          const movie = {
            localTitle: details.name["th"],
            posterUrl: details.image_url["port"],
            source: "sf",
            batch: false,
          };
          movies.push(movie);
        }
      }
    }
  } catch (err) {
    console.error("Error fetching from SFCinema:", err);
  }

  return movies;
}

module.exports = {
  fetchMovieListFromSf,
};
