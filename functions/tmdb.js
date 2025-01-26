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

const trailerQuery = {
  "ko-KR": " 영화 예고편",
  "ja-JP": " 映画 予告編",
  "fr-FR": " Bande-annonce Film",
  "en-CA": " Movie Trailer",
  "zh-TW": " 電影 預告片",
  "de-DE": " Film-Trailer",
  "en-US": " Movie Trailer",
  "hi-IN": " Movie Trailer",
  "zh-CN": " 电影 预告片",
  "es-ES": " Trailers de películas",
  "en-AU": " Movie Trailer",
  "th-TH": " มูฟวี่เทรลเลอร์",
};

/**
 * Fetches the first movie info from TMDb based on the title.
 * @param {String} countryCode - Country Code
 * @param {String} query - The search query.
 * @return {Promise<Object|null>} - A promise that resolves to the first Movie with trailerLink.
 */
async function searchMovieInfoByTitle(countryCode, query) {
  try {
    const response = await fetch(`https://api.themoviedb.org/3/search/movie?query=${encodeURIComponent(query)}&include_adult=false&language=${countryCode}&page=1`, options);
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    const data = await response.json();

    if (data.results && data.results.length > 0) {
      const searchId = data.results[0].id;
      const fullMovieInfo = await fetchFullMovieInfo(searchId, countryCode);
      return fullMovieInfo;
    } else {
      const trailerSearchTerm = trailerQuery[countryCode] || trailerQuery["en-US"];
      const trailerLink = await fetchFirstYouTubeVideoId(query + trailerSearchTerm, countryCode.slice(-2));

      if (trailerLink) return {trailerLink: trailerLink};
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

    let youtubeVideo = data.videos.results.find((video) => video.site === "YouTube" && video.type === "Trailer");

    if (!youtubeVideo) {
      youtubeVideo = data.videos.results.find((video) => video.site === "YouTube" && video.type === "Teaser");
    }

    const trailerLink = youtubeVideo ? youtubeVideo.key : await fetchFirstYouTubeVideoId(data.original_title + trailerQuery[countryCode], countryCode.slice(-2));
    // Select up to 4 cast members
    const selectedCast = data.credits.cast.slice(0, 4);

    // Filter crew to prioritize 'Director' job, and fill up with 'Directing' department if needed
    let directingCrew = data.credits.crew
        .filter((member) => member.job === "Director")
        .slice(0, 4); // First, select up to 4 "Director" jobs

    // If there are fewer than 4 "Director" members, add from "Directing" department
    if (directingCrew.length < 4) {
      const additionalDirectors = data.credits.crew
          .filter((member) => member.known_for_department === "Directing" && member.job !== "Director")
          .slice(0, 4 - directingCrew.length); // Only add enough to reach 4 total

      directingCrew = directingCrew.concat(additionalDirectors); // Combine both lists
    }
    // If no 'Directing' crew found, select up to 4 from the entire crew
    if (directingCrew.length === 0) {
      directingCrew = data.credits.crew.slice(0, 4);
    }

    return {
      ...data,
      trailerLink,
      credits: {
        cast: selectedCast,
        crew: directingCrew,
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
    if (movie.trailerUrl) fetchedMovie.trailerLink = movie.trailerUrl;
    return fetchedMovie;
  } catch (err) {
    console.error("Error fetching special movie information:", err);
    return null;
  }
}

/**
 * Fetches the special movie info from TMDb based on tmdb id
 * @param {String} country - Country
 * @param {String} countryCode - Country Code
 * @param {String} page - page number
 * @return {Promise<List<Object>|null>} - A promise that resolves to the movies
 */
async function fetchRunningMovieByCountryCode(country, countryCode, page) {
  try {
    const response = await fetch(`https://api.themoviedb.org/3/movie/now_playing?language=${countryCode}&page=${page}&region=${country}`, options);
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    const data = await response.json();

    if (data.results && data.results.length > 0) {
      return data.results;
    } else {
      return null;
    }
  } catch (err) {
    console.error("Error fetching movie information:", err);
    return null;
  }
}

/**
 * Fetches the special movie info from TMDb based on tmdb id
 * @param {String} country - Country
 * @param {String} countryCode - Country Code
 * @param {String} page - page number
 * @return {Promise<List<Object>|null>} - A promise that resolves to the movies
 */
async function fetchUpcomingMovieByCountryCode(country, countryCode, page) {
  try {
    const response = await fetch(`https://api.themoviedb.org/3/movie/upcoming?language=${countryCode}&page=${page}&region=${country}`, options);
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    const data = await response.json();

    if (data.results && data.results.length > 0) {
      return data.results;
    } else {
      return null;
    }
  } catch (err) {
    console.error("Error fetching movie information:", err);
    return null;
  }
}

module.exports = {
  searchMovieInfoByTitle,
  searchSpecialMovieInfoByTid,
  fetchRunningMovieByCountryCode,
  fetchUpcomingMovieByCountryCode,
};
