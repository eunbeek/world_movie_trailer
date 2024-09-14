/* eslint-disable max-len */
const axios = require("axios");

const inoxRunningUrl = "https://api3.inoxmovies.com/api/v1/booking/content/nowshowing";
const inoxUpcomingUrl = "https://api3.inoxmovies.com/api/v1/booking/content/comingsoon";

/**
 * Common headers for INOX API requests
 */
const inoxHeader = {
  "accept": "application/json, text/plain, */*",
  "accept-encoding": "gzip, deflate, br, zstd",
  "accept-language": "en-US,en;q=0.9,ko-KR;q=0.8,ko;q=0.7",
  "appversion": "1.0",
  "chain": "INOX",
  "city": "Mumbai-All",
  "content-type": "application/json",
  "country": "INDIA",
  "origin": "https://www.inoxmovies.com",
  "platform": "WEBSITE",
  "priority": "u=1, i",
  "referer": "https://www.inoxmovies.com/",
  "sec-ch-ua": "\"Not)A;Brand\";v=\"99\", \"Google Chrome\";v=\"127\", \"Chromium\";v=\"127\"",
  "sec-ch-ua-mobile": "?0",
  "sec-ch-ua-platform": "\"macOS\"",
  "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36",
};

const inoxUpcomingHeader = {
  "accept": "application/json, text/plain, */*",
  "accept-encoding": "gzip, deflate, br, zstd",
  "accept-language": "en-US,en;q=0.9,ko-KR;q=0.8,ko;q=0.7",
  "authorization": "Bearer",
  "appversion": "1.0",
  "chain": "INOX",
  "city": "Mumbai-All",
  "content-length": "48",
  "content-type": "application/json",
  "country": "INDIA",
  "origin": "https://www.inoxmovies.com",
  "platform": "WEBSITE",
  "priority": "u=1, i",
  "referer": "https://www.inoxmovies.com/",
  "sec-ch-ua": "\"Not)A;Brand\";v=\"99\", \"Google Chrome\";v=\"127\", \"Chromium\";v=\"127\"",
  "sec-ch-ua-mobile": "?0",
  "sec-ch-ua-platform": "\"macOS\"",
  "sec-fetch-dest": "empty",
  "sec-fetch-mode": "cors",
  "sec-fetch-site": "same-site",
  "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36",
};

/**
 * Helper function to convert a runtime string (e.g., "2h 30m") to minutes.
 * @param {string} runtimeString - The runtime string.
 * @return {number} - The total runtime in minutes.
 */
function convertRuntimeToMinutes(runtimeString) {
  const hoursMatch = runtimeString.match(/(\d+)h/);
  const minutesMatch = runtimeString.match(/(\d+)m/);

  const hours = hoursMatch ? parseInt(hoursMatch[1], 10) : 0;
  const minutes = minutesMatch ? parseInt(minutesMatch[1], 10) : 0;

  return hours * 60 + minutes;
}

/**
 * Helper function to convert a release date string (e.g., "Aug 15, 2024") to "YYYY-MM-DD" format.
 * @param {string} releaseDateString - The release date string.
 * @return {string} - The formatted release date.
 */
function formatReleaseDate(releaseDateString) {
  const date = new Date(releaseDateString);
  return date.toISOString().split("T")[0]; // Returns 'YYYY-MM-DD'
}

/**
 * Helper function to extract the YouTube ID from a trailer URL.
 * @param {string} url - The full YouTube URL.
 * @return {string} - The YouTube video ID.
 */
function extractYouTubeID(url) {
  const urlParts = url.split("v=");
  return urlParts.length > 1 ? urlParts[1] : url;
}

/**
 * Fetches movie data from INOX.
 * @return {Promise<Array>} - A promise that resolves to a list of movies from INOX.
 */
async function fetchMovieListFromInox() {
  const movies = [];

  try {
    // Fetch INOX movies (now showing)
    const runningResponse = await axios.post(
        inoxRunningUrl,
        {country: "India", city: "Mumbai-All"},
        {headers: inoxHeader},
    );

    if (runningResponse.status === 200) {
      const runningMovies = runningResponse.data.output.mv;

      // Process each film in "mv"
      runningMovies.forEach((item) => {
        const formattedCast = item.st ?
          item.starring.split(",").map((nm) => ({name: nm})) :
          [];
        const formattedCrew = item.director ? [{name: item.director}] : [];

        const posterUrl = item.miv || "";
        const trailerUrl = extractYouTubeID(item.mtrailerurl || "");
        const runtime = convertRuntimeToMinutes(item.mlength || "");
        const spec = item.synopsis || "No description available";

        const formattedReleaseDate = formatReleaseDate(item.releaseDate || "N/A");

        movies.push({
          localTitle: item.filmName || "Untitled",
          runtime: runtime,
          posterUrl: posterUrl,
          country: "IN",
          source: "inox",
          trailerUrl: trailerUrl,
          spec: spec,
          releaseDate: formattedReleaseDate,
          credits: {cast: formattedCast, crew: formattedCrew},
          isYoutube: true,
        });
      });
    } else {
      console.error("Failed to fetch INOX running data:", runningResponse.status);
    }

    // Fetch INOX movies (coming soon)
    const upcomingResponse = await axios.post(
        inoxUpcomingUrl,
        {country: "India", city: "Mumbai-All"},
        {headers: inoxUpcomingHeader},
    );

    if (upcomingResponse.status === 200) {
      const upcomingMovies = upcomingResponse.data.output.movies;

      // Process each film in "movies"
      upcomingMovies.forEach((item) => {
        const formattedCast = item.starring ?
          item.starring.split(",").map((nm) => ({name: nm})) :
          [];
        const formattedCrew = item.director ? [{name: item.director}] : [];

        const posterUrl = item.miv || "";
        const trailerUrl = extractYouTubeID(item.mtrailerurl || "");
        const runtime = convertRuntimeToMinutes(item.mlength || "");
        const spec = item.synopsis || "No description available";

        const formattedReleaseDate = formatReleaseDate(item.releaseDate || "N/A");

        movies.push({
          localTitle: item.filmName || "Untitled",
          runtime: runtime,
          posterUrl: posterUrl,
          country: "IN",
          source: "inox",
          trailerUrl: trailerUrl,
          spec: spec,
          releaseDate: formattedReleaseDate,
          credits: {cast: formattedCast, crew: formattedCrew},
          isYoutube: true,
        });
      });
    } else {
      console.error("Failed to fetch INOX upcoming data:", upcomingResponse.status);
    }
  } catch (err) {
    console.error("Error fetching INOX movies:", err);
  }

  return movies;
}

module.exports = {
  fetchMovieListFromInox,
};
