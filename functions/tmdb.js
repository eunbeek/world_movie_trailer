const {fetchFirstYouTubeVideoId} = require("./youtube");

/* eslint-disable max-len */
const options = {
  method: "GET",
  headers: {
    accept: "application/json",
    Authorization: "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJiYzJkYjEzZDdhMTJhYjgzYWQ0NmQyZTM2ZmJiZjUxMyIsIm5iZiI6MTcyNDk3MTMyNy40OTIzNTEsInN1YiI6IjY2YzJjNGMxYjE3YjliNTMxMTZlMzQ1NSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.BnU8r2hmsyzTk2eVNXROukxSlDrRbFhV7dlQmuH8AaU"
    ,
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
    const response = await fetch(`https://api.themoviedb.org/3/search/movie?query=${encodeURIComponent(query)}&include_adult=true&language=${countryCode}&page=1`, options);
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    const data = await response.json();

    if (data.results && data.results.length > 0) {
      const movie = data.results[0];
      const fullMovieInfo = await fetchFullMovieInfo(movie.id, countryCode);
      return fullMovieInfo;
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
 * Fetches full movie info including credits, videos, and details using append_to_response.
 * @param {String} movieId - TMDb movie ID.
 * @param {String} countryCode - Country Code
 * @return {Promise<Object|null>} - A promise that resolves to the full movie information.
 */
async function fetchFullMovieInfo(movieId, countryCode) {
  try {
    const response = await fetch(`https://api.themoviedb.org/3/movie/${movieId}?append_to_response=videos,credits&language=${countryCode}`, options);
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    const data = await response.json();

    const youtubeVideo = data.videos.results.find((video) => video.site === "YouTube");
    const trailerLink = youtubeVideo ? youtubeVideo.key : await fetchFirstYouTubeVideoId(data.original_title + " trailer");

    // Limit the cast and crew to 4 members each
    const limitedCast = data.credits.cast.slice(0, 4);
    const limitedCrew = data.credits.crew.slice(0, 4);

    return {
      ...data,
      trailerLink,
      credits: {
        cast: limitedCast,
        crew: limitedCrew,
      },
    };
  } catch (err) {
    console.error("Error fetching full movie information:", err);
    return null;
  }
}

/**
 * Fetches the special movie info from TMDb based on tmdb id
 * @param {Object} movie - The search id
 * @return {Promise<Object|null>} - A promise that resolves to the first Movie with trailerLink.
 */
async function searchSpecialMovieInfoByTid(movie) {
  try {
    const fetchedMovie = await fetchFullMovieInfo(movie.tid, "en-US");
    return fetchedMovie;
  } catch (err) {
    console.error("Error fetching special movie information:", err);
    return null;
  }
}

module.exports = {
  searchMovieInfoByTitle,
  searchSpecialMovieInfoByTid,
};
