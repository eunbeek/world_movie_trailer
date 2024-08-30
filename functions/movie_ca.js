/* eslint-disable max-len */
const axios = require("axios");

const cineplexUrl = "https://apis.cineplex.com/prod/cpx/theatrical/api/v1/movies?language=en-us&skip=0&take=100&removeIrrelevantFilms=true";

const cineplexHeaders = {
  "authority": "apis.cineplex.com",
  "method": "GET",
  "path": "/prod/cpx/theatrical/api/v1/movies?language=en-us&skip=11&take=12&removeIrrelevantFilms=true",
  "scheme": "https",
  "accept": "*/*",
  "accept-encoding": "gzip, deflate, br, zstd",
  "accept-language": "en-US,en;q=0.9,ko-KR;q=0.8,ko;q=0.7",
  "ocp-apim-subscription-key": "dcdac5601d864addbc2675a2e96cb1f8",
  "origin": "https://www.cineplex.com",
  "priority": "u=1, i",
  "referer": "https://www.cineplex.com/",
  "sec-ch-ua": "\"Not)A;Brand\";v=\"99\", \"Google Chrome\";v=\"127\", \"Chromium\";v=\"127\"",
  "sec-ch-ua-mobile": "?0",
  "sec-ch-ua-platform": "\"macOS\"",
  "sec-fetch-dest": "empty",
  "sec-fetch-mode": "cors",
  "sec-fetch-site": "same-site",
  "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36",
};


/**
 * Fetches movie data from Cineplex
 * @return {Promise<Array>}
 * A promise that resolves to a list of movies from Cineplex.
 */
async function fetchMovieListFromCineplex() {
  const movies = [];

  try {
    const response = await axios.get(cineplexUrl, {headers: cineplexHeaders});

    if (response.status === 200) {
      const data = response.data;

      data.items.forEach((item) => {
        movies.push({
          localTitle: item.name,
          runtime: item.runtimeInMinutes,
          posterUrl: item.largePosterImageUrl,
          country: "ca",
          source: "cineplex",
          batch: false,
        });
      });
    } else {
      console.error("Failed to fetch data:", response.status);
    }
  } catch (err) {
    console.error("Error fetching from Cineplex:", err);
  }

  return movies;
}
module.exports = {
  fetchMovieListFromCineplex,
};
