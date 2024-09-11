/* eslint-disable max-len */
const axios = require("axios");

const wandaHotShowUrl = `https://www.wandacinemas.com/api/proxy/content/pc/movie/hot_show.api?tt=1725872034582`;
const wandaComingSoonUrl = `https://www.wandacinemas.com/api/proxy/content/pc/movie/coming.api?tt=1725872034583`;

/**
 * Common headers for Wanda API requests
 */
const wandaHeaders = {
  "accept": "application/json, text/javascript, */*; q=0.01",
  "accept-encoding": "gzip, deflate, br, zstd",
  "accept-language": "en-US,en;q=0.9,ko-KR;q=0.8,ko;q=0.7",
  "connection": "keep-alive",
  "host": "www.wandacinemas.com",
  "referer": "https://www.wandacinemas.com/MovieList",
  "sec-ch-ua": "\"Not)A;Brand\";v=\"99\", \"Google Chrome\";v=\"127\", \"Chromium\";v=\"127\"",
  "sec-ch-ua-mobile": "?0",
  "sec-ch-ua-platform": "\"macOS\"",
  "sec-fetch-dest": "empty",
  "sec-fetch-mode": "cors",
  "sec-fetch-site": "same-origin",
  "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36",
  "x-requested-with": "XMLHttpRequest",
};

/**
 * Fetches movie data from Wanda (hot show and coming soon).
 * @return {Promise<Array>}
 * A promise that resolves to a list of movies from Wanda.
 */
async function fetchMovieListFromWanda() {
  const movies = [];

  try {
    // Fetch Wanda movies (hot show)
    const hotShowResponse = await axios.get(wandaHotShowUrl, {headers: wandaHeaders});
    if (hotShowResponse.status === 200) {
      const hotMovies = hotShowResponse.data.data.hotMovie;

      hotMovies.forEach((item) => {
        const formattedMovie = {
          localTitle: item.nameCN,
          releaseDate: new Date(item.releaseDate).toISOString().split("T")[0], // convert Unix timestamp to YYYY-MM-DD
          runtime: item.duration,
          posterUrl: item.coverUrl,
          spec: item.shortComment || "No synopsis available",
          batch: false,
        };
        movies.push(formattedMovie);
      });
    } else {
      console.error("Failed to fetch Wanda Hot Show data:", hotShowResponse.status);
    }

    // Fetch Wanda movies (coming soon)
    const comingSoonResponse = await axios.get(wandaComingSoonUrl, {headers: wandaHeaders});
    if (comingSoonResponse.status === 200) {
      let upcomingMovies = comingSoonResponse.data.data.incomingMovie;
      // Limit to the first 50 movies
      upcomingMovies = upcomingMovies.slice(0, 50);
      upcomingMovies.forEach((upcomingMovie) => {
        upcomingMovie.incomingMovie.forEach((item)=>{
          const formattedMovie = {
            localTitle: item.nameCN,
            releaseDate: new Date(item.releaseDate).toISOString().split("T")[0], // convert Unix timestamp to YYYY-MM-DD
            runtime: item.duration,
            posterUrl: item.coverUrl,
            spec: item.shortComment || "No synopsis available",
            batch: false,
          };
          movies.push(formattedMovie);
        });
      });
    } else {
      console.error("Failed to fetch Wanda Coming Soon data:", comingSoonResponse.status);
    }
  } catch (err) {
    console.error("Error fetching Wanda movies:", err);
  }

  return movies;
}

module.exports = {
  fetchMovieListFromWanda,
};
