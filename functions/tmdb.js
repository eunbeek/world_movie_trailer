const {fetchFirstYouTubeVideoId} = require("./youtube");

/* eslint-disable max-len */
const options = {
  method: "GET",
  headers: {
    accept: "application/json",
  },
};

/**
 * Fetches the first movie info from TMDb based on the title.
 * @param {String} countryCode - Country Code
 * @param {String} query - The search query.
 * @return {Promise<Object|null>} - A promise that resolves to the first Movie with trailerLink.
 */
async function searchMovieInfoByTitle(countryCode, query) {
  try {
    const response = await fetch(`https://api.themoviedb.org/3/search/movie?query=${encodeURIComponent(query)}&include_adult=true&language=${countryCode}&page=1&api_key=bc2db13d7a12ab83ad46d2e36fbbf513`, options);
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    const data = await response.json();

    if (data.results && data.results.length > 0) {
      const movie = data.results[0];
      const trailerLink = await searchMovieVideosByMovieId(movie.id, movie.original_title);
      if (trailerLink) {
        movie.trailerLink = trailerLink;
        return movie;
      } else {
        return null;
      }
    } else {
      console.log("No results found");
      return null;
    }
  } catch (err) {
    console.error("Error fetching movie information:", err);
    return null;
  }
}

/**
 * Fetches the trailer link from TMDb based on the movie ID.
 * @param {String} movieId - TMDb movie ID.
 * @param {String} movieTitle - TMDb movie title.
 * @return {Promise<string|null>} - A promise that resolves to the trailer YouTube key or null if not found.
 */
async function searchMovieVideosByMovieId(movieId, movieTitle) {
  try {
    const response = await fetch(`https://api.themoviedb.org/3/movie/${movieId}/videos?api_key=bc2db13d7a12ab83ad46d2e36fbbf513`, options);
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    const data = await response.json();

    if (data.results && data.results.length > 0) {
      const youtubeIdByTMDB = data.results.find((video) => video.site === "YouTube" && video.type === "Trailer");
      if (youtubeIdByTMDB) {
        return youtubeIdByTMDB.key;
      }
    }

    // If no results or no YouTube trailer found, search on YouTube directly
    console.log(`No TMDB trailer found, searching YouTube for ${movieTitle}`);
    const youtubeId = await fetchFirstYouTubeVideoId(movieTitle + " trailer");
    if (youtubeId) {
      return youtubeId;
    } else {
      console.log(`No YouTube trailer found for ${movieTitle}`);
      return null;
    }
  } catch (err) {
    console.error("Error fetching movie videos:", err);
    return null;
  }
}

module.exports = {
  searchMovieInfoByTitle,
};
