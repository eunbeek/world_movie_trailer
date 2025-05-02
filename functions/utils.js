/* eslint-disable max-len */
const admin = require("firebase-admin");
const {searchMovieInfoByTitle, searchSpecialMovieInfoByTid} = require("./tmdb");

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
async function processBatch(country, moviesData, processedCount, startTime, isTMDBID = false, isSpecial = false) {
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
        fetchedMovie = await searchSpecialMovieInfoByTid(movie);
      } else {
        fetchedMovie = await searchMovieInfoByTitle(country, movie.localTitle);
      }

      if (fetchedMovie) {
        if (isSpecial) {
          movie.posterUrl = `https://image.tmdb.org/t/p/w600_and_h900_bestv2${fetchedMovie.poster_path}`;
          movie.spec = fetchedMovie.overview ? fetchedMovie.overview : "";
          movie.releaseDate = fetchedMovie.release_date ? fetchedMovie.release_date : "";
          movie.runtime = fetchedMovie.runtime ? fetchedMovie.runtime : "";
          movie.credits = fetchedMovie.credits ? fetchedMovie.credits : {};
        } else {
          movie.posterUrl = fetchedMovie.poster_path ? `https://image.tmdb.org/t/p/w600_and_h900_bestv2${fetchedMovie.poster_path}` : movie.posterUrl;
          movie.trailerUrl = fetchedMovie.trailerLink || "";
          movie.country = movie.country ? movie.country : fetchedMovie.origin_country ? fetchedMovie.origin_country[0]: "";
          movie.spec = fetchedMovie.overview ? fetchedMovie.overview : movie.spec ? movie.spec: "";
          movie.releaseDate = movie.releaseDate? movie.releaseDate : fetchedMovie.release_date ? fetchedMovie.release_date : "";
          movie.runtime = fetchedMovie.runtime ? fetchedMovie.runtime : movie.runtime ? movie.runtime : "";
          movie.credits = fetchedMovie.credits ? fetchedMovie.credits : movie.credits ? movie.credits : {};
        }
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
      resolve(await processBatch(country, moviesData, processedCount, startTime));
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
  const bucket = admin.storage().bucket();
  const mainFileName = `movies_${country}.json`;
  const timestamp = new Date().toISOString(); // Get the current timestamp

  // Add the timestamp to each movie object or at the beginning of the JSON structure
  const dataToSave = {
    timestamp: timestamp, // Add the timestamp here
    movies: movies.filter((movie) => {
      return movie.trailerUrl !== "ERR404";
    }),
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
  }
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
async function updateMovieTrailer(country, title, newTrailerUrl) {
  const bucket = admin.storage().bucket();
  const fileName = `movies_${country}.json`;

  try {
    const file = bucket.file(fileName);
    const exists = await file.exists();

    if (!exists[0]) {
      throw new Error(`File not found: ${fileName}`);
    }

    // Read the file contents
    const fileContents = await file.download();
    const moviesData = JSON.parse(fileContents.toString());

    // Update the movie with the matching title
    let isUpdated = false;
    for (const movie of moviesData.movies) {
      if (movie.localTitle === title) {
        movie.trailerUrl = newTrailerUrl;
        isUpdated = true;
        break;
      }
    }

    if (!isUpdated) {
      console.log(`Movie with title "${title}" not found.`);
      return {success: false, message: `Movie "${title}" not found.`};
    }

    // Save the updated JSON back to Firebase Storage
    const updatedData = JSON.stringify(moviesData, null, 2);
    await file.save(updatedData, {
      metadata: {
        contentType: "application/json",
      },
    });

    console.log(`Trailer updated for "${title}" in ${fileName}.`);
    return {success: true, message: `Trailer updated for "${title}".`};
  } catch (error) {
    console.error("Error updating trailer:", error);
    return {success: false, error: error.message};
  }
}

/**
 * Deletes a movie by title from the JSON file in Firebase Storage.
 *
 * @param {string} country - The country code of the movie list.
 * @param {string} title - The title of the movie to delete.
 * @return {Promise<object>} - Result of the deletion.
 */
async function deleteMovieByManual(country, title) {
  if (!country || !title) {
    throw new Error("Country and title are required.");
  }

  const bucket = admin.storage().bucket();
  const fileName = `movies_${country.toLowerCase()}.json`; // JSON file name for the country
  const file = bucket.file(fileName);

  // Check if the file exists
  const [exists] = await file.exists();
  if (!exists) {
    return {success: false, message: `File for country ${country} does not exist.`};
  }

  // Read the file content
  const [fileContents] = await file.download();
  const moviesData = JSON.parse(fileContents.toString());

  // Find and remove the movie by title
  const filteredMovies = moviesData.movies.filter((movie) => movie.localTitle !== title);

  if (filteredMovies.length === moviesData.movies.length) {
    return {success: false, message: `Movie titled "${title}" not found.`};
  }

  // Save the updated movie list back to Firebase Storage
  moviesData.movies = filteredMovies;
  await file.save(JSON.stringify(moviesData, null, 2), {contentType: "application/json"});

  return {success: true, message: `Movie titled "${title}" deleted successfully.`};
}

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
  saveMoviesAsJson,
  saveQuotesAsJson,
  updateMovieTrailer,
  deleteMovieByManual,
  updatePromotionUrl,
};
