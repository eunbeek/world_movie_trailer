/* eslint-disable max-len */
const axios = require("axios");
const cheerio = require("cheerio");

const filmaffinityRunningUrl = "https://www.filmaffinity.com/es/cat_new_th_es.html";
const filmaffinityUpcomingUrl = "https://www.filmaffinity.com/es/rdcat.php?id=upc_th_es";
const filmaffinityHeader = {
  "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
  "Accept-Encoding": "gzip, deflate, br, zstd",
  "Accept-Language": "en-US,en;q=0.9,ko-KR;q=0.8,ko;q=0.7",
  "Cache-Control": "max-age=0",
  "If-Modified-Since": "Thu, 20 Mar 2025 04:18:14 GMT",
  "Priority": "u=0, i",
  "Referer": "https://www.filmaffinity.com/es/rdcat.php?id=upc_th_es",
  "Sec-CH-UA": "\"Chromium\";v=\"134\", \"Not:A-Brand\";v=\"24\", \"Google Chrome\";v=\"134\"",
  "Sec-CH-UA-Mobile": "?0",
  "Sec-CH-UA-Platform": "\"macOS\"",
  "Sec-Fetch-Dest": "document",
  "Sec-Fetch-Mode": "navigate",
  "Sec-Fetch-Site": "same-origin",
  "Sec-Fetch-User": "?1",
  "Upgrade-Insecure-Requests": "1",
  "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_0_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36",
};

/**
 * Fetches running movies from FilmAffinity.
 * @return {Promise<Array>} A promise that resolves to a list of movies from FilmAffinity.
 */
async function fetchRunningFromFilmaffinity() {
  const movies = [];

  try {
    const response = await axios.get(filmaffinityRunningUrl, {headers: filmaffinityHeader});

    if (response.status !== 200) {
      throw new Error("Failed to fetch FilmAffinity Now Playing movies.");
    }

    const $ = cheerio.load(response.data);

    $(".movie-poster").each((_, element) => {
      const title = $(element).find(".movie-title a").text().trimEnd();
      const posterUrl = $(element).find("img").attr("data-src") || $(element).find("img").attr("src");

      if (title && posterUrl) {
        movies.push({
          localTitle: title,
          posterUrl: posterUrl,
          source: "filmAffinity",
          batch: false,
        });
      }
    });

    return movies;
  } catch (err) {
    console.error("Error fetching from FilmAffinity:", err);
    return [];
  }
}

/**
 * Fetches upcoming movies from Filmaffinity.
 * @param {Array} runningMovies
 * @return {Promise<Array>} - A promise that resolves to a list of movies.
 */
async function fetchUpcomingFromFilmaffinity(runningMovies) {
  const movies = [];

  try {
    const response = await axios.get(filmaffinityUpcomingUrl, {headers: filmaffinityHeader});

    if (response.status !== 200) {
      throw new Error("Failed to fetch Filmaffinity upcoming movies.");
    }

    const $ = cheerio.load(response.data);

    $(".movie-card").each((_, element) => {
      const title = $(element).find(".mc-right h3 a").attr("title");
      const posterUrl = $(element).find(".mc-poster img").attr("src") || "";

      if (runningMovies.some((movie) => movie.localTitle.trim() === title.trim()) || movies.some((movie) => movie.localTitle.trim() === title.trim())) {
        return;
      }

      if (title && posterUrl) {
        movies.push({
          localTitle: title,
          posterUrl: posterUrl,
          source: "filmAffinity",
          batch: false,
        });
      }
    });

    return movies;
  } catch (err) {
    console.error("Error fetching from Filmaffinity:", err);
    return [];
  }
}

module.exports = {
  fetchRunningFromFilmaffinity,
  fetchUpcomingFromFilmaffinity,
};
