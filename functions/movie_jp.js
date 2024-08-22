/* eslint-disable max-len */
const axios = require("axios");
const cheerio = require("cheerio");

const eigaRunning = "https://eiga.com/now/";
const eigaUpcoming = "https://eiga.com/movie/video/upcoming";
const eigaMore = "https://eiga.com/now/all/release/2/";
const eigaMoreUpcoming = "https://eiga.com/movie/video/coming/";

/**
 * Fetches all running movies from EIGA (both current and more).
 * @param {Array} [moviesJP] - List of movies to avoid duplicates.
 * @return {Promise<Array>} - A promise that resolves to a list of running movies.
 */
async function fetchRunningFromEIGA(moviesJP = []) {
  const urls = [eigaRunning, eigaMore];
  const movies = [];

  for (const url of urls) {
    try {
      const response = await axios.get(url);

      if (response.status !== 200) {
        throw new Error("Failed to load EIGA movies");
      }

      const $ = cheerio.load(response.data);
      const movieBoxes = $("section div.list-block");

      const promises = movieBoxes.map(async (i, movieBox) => {
        const aTag = $(movieBox).find("div.img-box a");
        if (aTag) {
          const title = $(aTag).find("img").attr("alt");
          if (moviesJP.length > 0 && moviesJP.some((movieJP) => movieJP.localTitle.trim() === title.trim())) return;
          const posterUrl = $(aTag).find("img").attr("src");
          movies.push({
            localTitle: title.trim(),
            posterUrl: posterUrl,
            country: "jp",
            source: "eiga",
          });
        }
      }).get();

      await Promise.all(promises);
    } catch (error) {
      console.error("Error fetching from EIGA:", error);
    }
  }

  return movies;
}

/**
 * Fetches all upcoming movies from EIGA (both current and more upcoming).
 * @param {Array} [moviesJP] - List of movies to avoid duplicates.
 * @return {Promise<Array>} - A promise that resolves to a list of upcoming movies.
 */
async function fetchUpcomingFromEIGA(moviesJP = []) {
  const urls = [eigaUpcoming, eigaMoreUpcoming];
  const movies = [];

  for (const url of urls) {
    try {
      const response = await axios.get(url);

      if (response.status !== 200) {
        throw new Error("Failed to load EIGA movies");
      }

      const $ = cheerio.load(response.data);
      const movieBoxes = $("li.col-s-4");

      const promises = movieBoxes.map(async (i, movieBox) => {
        const aTag = $(movieBox).find("a");
        if (aTag) {
          const title = $(movieBox).find("div.img-thumb img").attr("alt");

          if (moviesJP.length > 0 && moviesJP.some((movieJP) => movieJP.localTitle.trim() === title.trim())) return;
          const posterUrl = $(movieBox).find("div.img-thumb").find("img").attr("src");
          movies.push({
            localTitle: title.trim(),
            posterUrl: posterUrl,
            country: "jp",
            source: "eiga",
          });
        }
      }).get();

      await Promise.all(promises);
    } catch (error) {
      console.error("Error fetching from EIGA:", error);
    }
  }

  return movies;
}

module.exports = {
  fetchRunningFromEIGA,
  fetchUpcomingFromEIGA,
};
