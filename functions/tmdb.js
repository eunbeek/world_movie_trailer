const {fetchFirstYouTubeVideoId} = require("./youtube");

/* eslint-disable max-len */
const options = {
  method: "GET",
  headers: {
    accept: "application/json",
    Authorization: "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJiYzJkYjEzZDdhMTJhYjgzYWQ0NmQyZTM2ZmJiZjUxMyIsIm5iZiI6MTcyNDEzNzQzMi4yNTQ0Nywic3ViIjoiNjZjMmM0YzFiMTdiOWI1MzExNmUzNDU1Iiwic2NvcGVzIjpbImFwaV9yZWFkIl0sInZlcnNpb24iOjF9.HibWV0GxB4LevBZpRVwY8ws1xfNtk2xaWO-YViesV2w",
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
      const trailerLink = await searchMovieVideosByMovieId(movie.id, movie.original_title, countryCode);
      if (trailerLink) {
        movie.trailerLink = trailerLink;
        movie.credits = await searchCreditByMovieId(movie.id, countryCode);
        const movieDetails = await searchDetailsByMovieId(movie.id, countryCode);
        movie.runtime = movieDetails.runtime;
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
 * @param {String} countryCode - Country Code
 * @return {Promise<string|null>} - A promise that resolves to the trailer YouTube key or null if not found.
 */
async function searchMovieVideosByMovieId(movieId, movieTitle, countryCode) {
  try {
    const response = await fetch(`https://api.themoviedb.org/3/movie/${movieId}/videos?language=${countryCode}`, options);
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

/**
 * Fetches the movie credit from TMDb based on the movie ID.
 * @param {String} movieId - TMDb movie ID.
 * @param {String} countryCode - Country Code
 * @return {Promise<Object|null>} - A promise that resolves to the credit or null if not found.
 */
async function searchCreditByMovieId(movieId, countryCode) {
  try {
    const response = await fetch(`https://api.themoviedb.org/3/movie/${movieId}/credits?language=${countryCode}`, options);
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    const data = await response.json();

    if (data) {
      // Limit the cast and crew to 4 members each
      const limitedCast = data.cast.slice(0, 4);
      const limitedCrew = data.crew.slice(0, 4);

      // Return the limited data
      return {
        cast: limitedCast,
        crew: limitedCrew,
      };
    } else {
      return {cast: [], crew: []};
    }
  } catch (err) {
    console.error("Error fetching movie credits:", err);
    return null;
  }
}
/**
 * Fetches the movie runtime from TMDb based on the movie ID.
 * @param {String} movieId - TMDb movie ID.
 * @param {String} countryCode - Country Code
 * @return {Promise<Object|null>} - A promise that resolves to the runtime or null if not found.
 */
async function searchDetailsByMovieId(movieId, countryCode) {
  try {
    const response = await fetch(`https://api.themoviedb.org/3/movie/${movieId}?language=${countryCode}`, options);
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    const data = await response.json();
    if (data.runtime || data.release_date || data.overview) {
      return data;
    } else {
      return null;
    }
  } catch (err) {
    console.error("Error fetching movie credits:", err);
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
    const fetchedMovie={};
    console.log(movie);
    fetchedMovie.trailerLink = movie.trailerUrl;
    fetchedMovie.credits = await searchCreditByMovieId(movie.tid, "en-US");
    const movieDetails = await searchDetailsByMovieId(movie.tid, "en-US");
    fetchedMovie.runtime = movieDetails.runtime;
    fetchedMovie.release_date = movieDetails.release_date;
    fetchedMovie.overview = movieDetails.overview;
    return fetchedMovie;
  } catch (err) {
    console.error("Error fetching movie information:", err);
    return null;
  }
}
module.exports = {
  searchMovieInfoByTitle,
  searchSpecialMovieInfoByTid,
};
