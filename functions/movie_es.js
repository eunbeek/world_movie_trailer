/* eslint-disable max-len */
const axios = require("axios");

const kinepolisRunningUrl = "https://kinepolisweb-programmation.kinepolis.com/api/Programmation/ES/ES/WWW/Cinema/KinepolisSpain";
const kinepolisUpcomingUrl = "https://kinepolisweb-programmation.kinepolis.com/api/FutureReleases/ES/ES/KinepolisSpain/WWW";
const kinepolisImageUrl = "https://cdn.kinepolis.es/images";
const kinepolisHeader = {
  "accept": "application/json, text/javascript, */*; q=0.01",
  "referer": "https://kinepolis.es/",
  "sec-ch-ua": "\"Not)A;Brand\";v=\"99\", \"Google Chrome\";v=\"127\", \"Chromium\";v=\"127\"",
  "sec-ch-ua-mobile": "?0",
  "sec-ch-ua-platform": "\"macOS\"",
  "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36",
  "accept-encoding": "gzip, deflate, br, zstd",
  "accept-language": "en-US,en;q=0.9,ko-KR;q=0.8,ko;q=0.7",
  "origin": "https://kinepolis.es",
  "priority": "u=1, i",
  "sec-fetch-dest": "empty",
  "sec-fetch-mode": "cors",
  "sec-fetch-site": "cross-site",
};

/**
 * Fetches movie data from Kinepolis
 * @return {Promise<Array>}
 * A promise that resolves to a list of movies from Kinepolis.
 */
async function fetchMovieListFromKinepolis() {
  const movies = [];

  try {
    // Loop over the URLs
    for (const url of [kinepolisRunningUrl, kinepolisUpcomingUrl]) {
      const response = await axios.get(url, {headers: kinepolisHeader});

      if (response.status === 200) {
        const data = response.data;

        // Process each film
        data.films.forEach((item) => {
          // Format the release date (if available)
          const formattedDate = item.releaseDate ? item.releaseDate.split("T")[0] : "N/A";
          // Format the cast and crew in the specified format
          const formattedCast = item.filmPersons ? item.filmPersons.filter((person) => person.role === "A").map((cast) => ({name: cast.firstName + " " + cast.lastName})) :[];

          const formattedCrew = item.filmPersons ? item.filmPersons.filter((person) => person.role === "D").map((director) => ({name: director.firstName + " " + director.lastName})) :[];

          // Extract poster URL and trailer URL
          const posterUrl = item.images && item.images.length > 0 ? kinepolisImageUrl + item.images[0].url : "";
          const trailerUrl = item.trailers && item.trailers.length > 0 ? item.trailers[0].url : ""; // Adjust if you know how the trailer URL is stored in the API

          // Extract movie runtime and description
          const runtime = item.duration;
          const spec = item.synopsis || "No description available";
          console.log( item.countryOfOrigin);
          // Add the movie details to the movies array
          movies.push({
            localTitle: item.title || "Untitled", // Movie title
            runtime: runtime,
            posterUrl: posterUrl,
            country: item.countryOfOrigin ? item.countryOfOrigin.code : "Unknown",
            source: "kinepolis",
            trailerUrl: trailerUrl,
            spec: spec,
            releaseDate: formattedDate,
            credits: {cast: formattedCast, crew: formattedCrew},
            isYoutube: false,
          });
        });
      } else {
        console.error("Failed to fetch data:", response.status);
      }
    }
  } catch (err) {
    console.error("Error fetching from Kinepolis:", err);
  }

  return movies;
}

module.exports = {
  fetchMovieListFromKinepolis,
};
