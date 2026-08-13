/* eslint-disable max-len */
const admin = require("firebase-admin");
const {searchMovieInfoByTitle, searchMovieInfoByTid, searchSpecialMovieInfoByTid} = require("./tmdb");
const {publishMovies} = require("./movie_publisher");

/**
 * Processes a batch of movies to fetch trailers and updates the list.
 *
 * @param {string} country - The country code for the movies.
 * @param {Array} moviesData - The list of movies to process.
 * @param {number} processedCount - The count of processed movies.
 * @param {number} startTime - The start time of the batch process.
 * @param {boolean} [isTMDBID=false] - Whether the movies belong to a
 * @param {boolean} [isSpecial=false] - Whether the movies belong to a
 * @return {Promise<Array>} The updated list of movies.
 */
async function processBatch(country, moviesData, processedCount, startTime, isTMDBID = false) {
  const unprocessedMovies = moviesData.filter((movie) => !movie.batch);
  console.log(`unprocessMovies: ${unprocessedMovies.length}`);
  if (unprocessedMovies.length === 0) {
    console.log("All movies processed. No further action needed.");
    return moviesData;
  }

  const moviesToProcess = unprocessedMovies.slice(0, 20);

  for (const movie of moviesToProcess) {
    try {
      let fetchedMovie = [];

      if (isTMDBID) {
        fetchedMovie = await searchMovieInfoByTid(movie);
      } else {
        fetchedMovie = await searchMovieInfoByTitle(country, movie.localTitle);
      }

      if (fetchedMovie) {
        movie.tid = movie.tid || fetchedMovie.id || "";
        movie.title = fetchedMovie.title || movie.title || movie.localTitle || "";
        movie.originCountry = fetchedMovie.origin_country && fetchedMovie.origin_country[0] || movie.originCountry || "";
        movie.posterUrl = fetchedMovie.poster_path ? `https://image.tmdb.org/t/p/w600_and_h900_bestv2${fetchedMovie.poster_path}` : movie.posterUrl;
        movie.trailerUrl = fetchedMovie.trailerLink || "";
        movie.country = movie.country ? movie.country : fetchedMovie.origin_country ? fetchedMovie.origin_country[0]: "";
        movie.spec = fetchedMovie.overview ? fetchedMovie.overview : movie.spec ? movie.spec: "";
        movie.releaseDate = movie.releaseDate? movie.releaseDate : fetchedMovie.release_date ? fetchedMovie.release_date : "";
        movie.runtime = fetchedMovie.runtime ? fetchedMovie.runtime : movie.runtime ? movie.runtime : "";
        movie.credits = fetchedMovie.credits ? fetchedMovie.credits : movie.credits ? movie.credits : {};
      }

      movie.batch = true;
    } catch (error) {
      console.error(`Error processing movie ${movie.localTitle}:`, error);
    }
  }

  processedCount += moviesToProcess.length;

  if (processedCount >= 200 || (Date.now() - startTime) > 500000) { // 500,000 ms = 8 minutes 20 seconds
    console.log("Stopping processing to avoid timeout.");
    return moviesData;
  }

  console.log("Batch processed. Waiting 12 seconds for the next batch.");
  return new Promise((resolve) => {
    setTimeout(async () => {
      resolve(await processBatch(country, moviesData, processedCount, startTime, isTMDBID));
    }, 12000); // Trigger next batch in 12 seconds
  });
}


/**
 * Processes a batch of special movies to fetch trailers and updates the list.
 *
 * @param {string} country - The country code for the movies.
 * @param {Array} moviesData - The list of movies to process.
 * @param {number} processedCount - The count of processed movies.
 * @param {number} startTime - The start time of the batch process.
 * @return {Promise<Array>} The updated list of movies.
 */
async function processBatchForSpecial(country, moviesData, processedCount, startTime) {
  const unprocessedMovies = moviesData.filter((movie) => !movie.batch);
  console.log(`unprocessMovies: ${unprocessedMovies.length}`);
  if (unprocessedMovies.length === 0) {
    console.log("All movies processed. No further action needed.");
    return moviesData;
  }

  const moviesToProcess = unprocessedMovies.slice(0, 20);

  for (const movie of moviesToProcess) {
    try {
      let fetchedMovie = [];
      fetchedMovie = await searchSpecialMovieInfoByTid(movie);

      if (fetchedMovie) {
        movie.posterUrl = `https://image.tmdb.org/t/p/w600_and_h900_bestv2${fetchedMovie.poster_path}`;
        movie.spec = fetchedMovie.overview ? fetchedMovie.overview : "";
        movie.releaseDate = fetchedMovie.release_date ? fetchedMovie.release_date : "";
        movie.runtime = fetchedMovie.runtime ? fetchedMovie.runtime : "";
        movie.credits = fetchedMovie.credits ? fetchedMovie.credits : {};
      }

      movie.batch = true;
    } catch (error) {
      console.error(`Error processing movie ${movie.localTitle}:`, error);
    }
  }

  processedCount += moviesToProcess.length;

  console.log("Batch processed. Waiting 12 seconds for the next batch.");
  return new Promise((resolve) => {
    setTimeout(async () => {
      resolve(await processBatchForSpecial(country, moviesData, processedCount, startTime));
    }, 12000); // Trigger next batch in 12 seconds
  });
}

/**
   * Saves the list of movies as a JSON file in Firebase Storage.
   *
   * @param {string} country - The country code for the movies.
   * @param {Array} movies - The list of movies to save.
   * @return {Promise<void>} Saves the movie list in Firebase Storage.
   */
async function saveMoviesAsJson(country, movies) {
  return await publishMovies(country, movies);
}

/**
   * Saves the list of quotes as a JSON file in Firebase Storage.
   *
   * @param {string} country - The country code for the movies.
   * @param {Array} quotes - The list of quotes to save.
   * @return {Promise<void>} Saves the quote list in Firebase Storage.
   */
async function saveQuotesAsJson(country, quotes) {
  const bucket = admin.storage().bucket();
  const mainFileName = `quotes_${country}.json`;
  const timestamp = new Date().toISOString(); // Get the current timestamp

  // Add the timestamp to each quote object or at the beginning of the JSON structure
  const dataToSave = {
    timestamp: timestamp, // Add the timestamp here
    quotes: quotes,
  };

  const jsonData = JSON.stringify(dataToSave, null, 2);

  try {
    // Overwrite the main file
    await bucket.file(mainFileName).save(jsonData, {
      metadata: {
        contentType: "application/json",
      },
    });
    console.log(`File ${mainFileName} saved successfully with timestamp ${timestamp}`);
  } catch (error) {
    console.error("Error saving file to Firebase Storage:", error);
    throw error;
  }
}

/**
   * Saves the list of quotes as a JSON file in Firebase Storage.
   *
   * @param {string} country - The country code for the movies.
   * @param {string} title - The movie title
   * @param {string} newTrailerUrl - new trailer url
   * @return {Promise<void>} Saves the quote list in Firebase Storage.
   */
/**
   * Saves the list of quotes as a JSON file in Firebase Storage.
   *
   * @param {string} newUrl - new promotion url
   * @return {Promise<void>} Saves the quote list in Firebase Storage.
   */
async function updatePromotionUrl(newUrl) {
  const bucket = admin.storage().bucket();
  const fileName = `promotion_url.json`;

  try {
    const file = bucket.file(fileName);

    await file.save(JSON.stringify({url: newUrl}));

    console.log(`Promotion Url updated for "${newUrl}" in promotion_url.json.`);
    return {success: true, message: `Promotion Url updated for "${newUrl}".`};
  } catch (error) {
    console.error("Error updating Promotion Url:", error);
    return {success: false, error: error.message};
  }
}

module.exports = {
  processBatch,
  processBatchForSpecial,
  saveMoviesAsJson,
  saveQuotesAsJson,
  updatePromotionUrl,
};
