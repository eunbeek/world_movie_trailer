/* eslint-disable max-len */
const axios = require("axios");

const showTimeUrl = "https://capi.showtimes.com.tw/1/app/bootstrap";

const showTimeHeaders = {
  "accept": "application/json, text/plain, */*",
  "authorization": "undefined", // If you have a valid token, replace "undefined" with it
  "referer": "https://www.showtimes.com.tw/",
  "sec-ch-ua": "\"Not)A;Brand\";v=\"99\", \"Google Chrome\";v=\"127\", \"Chromium\";v=\"127\"",
  "sec-ch-ua-mobile": "?0",
  "sec-ch-ua-platform": "\"macOS\"",
  "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36",
};


/**
 * Fetches movie data from ShowTime
 * @return {Promise<Array>}
 * A promise that resolves to a list of movies from ShowTime.
 */
async function fetchMovieListFromShowTime() {
  const movies = [];

  try {
    const response = await axios.get(showTimeUrl, {headers: showTimeHeaders});

    if (response.status === 200) {
      const data = response.data;
      data.payload.programs.forEach((item) => {
        const formattedDate = item.availableAt.split("T")[0];
        const formattedCast = item.meta.authors ? item.meta.authors.map((cast) => ({name: cast})) : [];
        const formattedCrew = item.meta.directors ? item.meta.directors.map((crew) => ({name: crew})) : [];
        const posterUrl = item.coverImagePortrait ? item.coverImagePortrait.url : "";
        const trailerUrl = item.previewVideo ? item.previewVideo.data : "";
        const runtime = Math.round(item.duration / 60);
        const spec = item.description || "No description available";

        movies.push({
          localTitle: item.name,
          runtime: runtime,
          posterUrl: posterUrl,
          source: "showtimes",
          trailerUrl: trailerUrl,
          spec: spec,
          releaseDate: formattedDate,
          credits: {cast: formattedCast, crew: formattedCrew},
        });
      });
    } else {
      console.error("Failed to fetch data:", response.status);
    }
  } catch (err) {
    console.error("Error fetching from ShowTime:", err);
  }

  return movies;
}


module.exports = {
  fetchMovieListFromShowTime,
};
