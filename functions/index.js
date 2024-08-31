/* eslint-disable max-len */
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const {fetchMovieListFromCgv, fetchMovieListFromLotte} = require("./movie_kr");
const {fetchRunningFromEIGA, fetchUpcomingFromEIGA} = require("./movie_jp");
const {fetchMovieListFromCineplex} = require("./movie_ca");
const {fetchMovieListFromShowTime} = require("./movie_tw");
const {fetchMovieListFromUga} = require("./movie_fr");
const {fetchMovieListFromTraumpalast} = require("./movie_de");
const {fetchMovieListFromTMDBByUS} = require("./movie_us");
const {fetchMovieInSpecialSection} = require("./movie_special");
const {searchMovieInfoByTitle, searchSpecialMovieInfoByTid} = require("./tmdb");

admin.initializeApp();

// /**
//  * Fetches movies from CGV and Lotte, processes trailers, and saves the result.
//  * Scheduled to run every Monday at 09:00 AM KST.
//  *
//  * @returns {Promise<null>} Returns null when the function completes.
//  */
// exports.fetchMovieListKR = functions
//     .runWith({timeoutSeconds: 540})
//     .pubsub
//     .schedule("0 9 * * 1")
//     .timeZone("America/Toronto") // Ensure timezone is KST if required
//     .onRun(async () => {
//       const processedCount = 0;
//       const startTime = Date.now();

//       const lotteMovies = await fetchMovieListFromLotte();
//       const cgvMovies = await fetchMovieListFromCgv(lotteMovies);
//       const allMovies = [...lotteMovies, ...cgvMovies];

//       const moviesWithDetails = await processBatch("ko-KR", allMovies, processedCount, startTime);

//       await saveMoviesAsJson("kr", moviesWithDetails);

//       const timestamp = new Date().toISOString();
//       console.log(`Success: [${timestamp}] Country: KR, Movie Count: ${moviesWithDetails.length}`);

//       return null;
//     });

// /**
//  * Fetches movies from EIGA, processes trailers, and saves the result.
//  * Scheduled to run every Tuesday at 09:00 AM JST.
//  *
//  * @returns {Promise<null>} Returns null when the function completes.
//  */
// exports.fetchMovieListJP = functions
//     .runWith({timeoutSeconds: 540})
//     .pubsub
//     .schedule("0 9 * * 2")
//     .timeZone("America/Toronto") // Ensure timezone is JST if required
//     .onRun(async () => {
//       const processedCount = 0;
//       const startTime = Date.now();

//       const runningMovies = await fetchRunningFromEIGA(false);
//       const upcomingMovies = await fetchUpcomingFromEIGA(false);
//       const allMovies = [...runningMovies, ...upcomingMovies];

//       const moviesWithTrailer = await processBatch("ja-JP", allMovies, processedCount, startTime);

//       await saveMoviesAsJson("jp", moviesWithTrailer);

//       const timestamp = new Date().toISOString();
//       console.log(`Success: [${timestamp}] Country: JP, Movie Count: ${moviesWithTrailer.length}`);

//       return null;
//     });

// /**
//  * Fetches movies from Cineplex, processes trailers, and saves the result.
//  * Scheduled to run every Wednesday at 09:00 AM EST.
//  *
//  * @returns {Promise<null>} Returns null when the function completes.
//  */
// exports.fetchMovieListCA = functions
//     .runWith({timeoutSeconds: 540})
//     .pubsub
//     .schedule("0 9 * * 3")
//     .timeZone("America/Toronto")
//     .onRun(async () => {
//       const processedCount = 0;
//       const startTime = Date.now();

//       const allMovies = await fetchMovieListFromCineplex();

//       const moviesWithDetails = await processBatch("en-CA", allMovies, processedCount, startTime);

//       await saveMoviesAsJson("ca", moviesWithDetails);

//       const timestamp = new Date().toISOString();
//       console.log(`Success: [${timestamp}] Country: CA, Movie Count: ${moviesWithDetails.length}`);

//       return null;
//     });

// /**
//  * Fetches movies from ShowTime, processes trailers, and saves the result.
//  * Scheduled to run every Thursday at 09:00 AM CST.
//  *
//  * @returns {Promise<null>} Returns null when the function completes.
//  */
// exports.fetchMovieListTW = functions
//     .runWith({timeoutSeconds: 540})
//     .pubsub
//     .schedule("0 9 * * 4")
//     .timeZone("America/Toronto") // Ensure timezone is CST if required
//     .onRun(async () => {
//       const allMovies = await fetchMovieListFromShowTime();

//       await saveMoviesAsJson("tw", allMovies);

//       const timestamp = new Date().toISOString();
//       console.log(`Success: [${timestamp}] Country: TW, Movie Count: ${allMovies.length}`);

//       return null;
//     });

// /**
//  * Fetches movies from UGA, processes trailers, and saves the result.
//  * Scheduled to run every Friday at 09:00 AM CET.
//  *
//  * @returns {Promise<null>} Returns null when the function completes.
//  */
// exports.fetchMovieListFR = functions
//     .runWith({timeoutSeconds: 540})
//     .pubsub
//     .schedule("0 9 * * 5")
//     .timeZone("America/Toronto") // Ensure timezone is CET if required
//     .onRun(async () => {
//       const processedCount = 0;
//       const startTime = Date.now();

//       const allMovies = await fetchMovieListFromUga();

//       const moviesWithDetails = await processBatch("fr-FR", allMovies, processedCount, startTime);

//       await saveMoviesAsJson("fr", moviesWithDetails);

//       const timestamp = new Date().toISOString();
//       console.log(`Success: [${timestamp}] Country: FR, Movie Count: ${moviesWithDetails.length}`);

//       return null;
//     });

// /**
//  * Fetches movies from Traumpalast, processes trailers, and saves the result.
//  * Scheduled to run every Saturday at 09:00 AM CET.
//  *
//  * @returns {Promise<null>} Returns null when the function completes.
//  */
// exports.fetchMovieListDE = functions
//     .runWith({timeoutSeconds: 540})
//     .pubsub
//     .schedule("0 9 * * 6")
//     .timeZone("America/Toronto") // Ensure timezone is CET if required
//     .onRun(async () => {
//       const processedCount = 0;
//       const startTime = Date.now();

//       const allMovies = await fetchMovieListFromTraumpalast();

//       const moviesWithDetails = await processBatch("de-DE", allMovies, processedCount, startTime);

//       await saveMoviesAsJson("de", moviesWithDetails);

//       const timestamp = new Date().toISOString();
//       console.log(`Success: [${timestamp}] Country: DE, Movie Count: ${moviesWithDetails.length}`);

//       return null;
//     });

// /**
//  * Fetches movies from TMDB by US region, processes trailers, and saves the result.
//  * Scheduled to run every Sunday at 09:00 AM EST.
//  *
//  * @returns {Promise<null>} Returns null when the function completes.
//  */
// exports.fetchMovieListUS = functions
//     .runWith({timeoutSeconds: 540})
//     .pubsub
//     .schedule("0 9 * * 7")
//     .timeZone("America/Toronto")
//     .onRun(async () => {
//       const processedCount = 0;
//       const startTime = Date.now();

//       const allMovies = await fetchMovieListFromTMDBByUS();

//       const moviesWithDetails = await processBatch("en-US", allMovies, processedCount, startTime, true);

//       await saveMoviesAsJson("us", moviesWithDetails);

//       const timestamp = new Date().toISOString();
//       console.log(`Success: [${timestamp}] Country: US, Movie Count: ${moviesWithDetails.length}`);

//       return null;
//     });

/**
 * Fetches movies in the special section by director, processes trailers, and saves the result.
 * Can be triggered via an HTTP request.
 *
 * @param {Object} req - The request object.
 * @param {Object} res - The response object.
 * @returns {Promise<void>} Sends a JSON response when the function completes.
 */
exports.fetchSpeicalSectionByDirector = functions.runWith({timeoutSeconds: 540}).https.onRequest(async (req, res) => {
  try {
    const processedCount = 0;
    const startTime = Date.now();

    const specialMovies = await fetchMovieInSpecialSection();

    const moviesWithTrailer = await processBatch("en-US", specialMovies, processedCount, startTime, true);

    await saveMoviesAsJson("special", moviesWithTrailer);

    const timestamp = new Date().toISOString();
    console.log(`Success: [${timestamp}] Country: Special, Movie Count: ${moviesWithTrailer.length}`);

    res.status(200).json({
      success: true,
      timestamp,
      country: "Special",
      movieCount: specialMovies.length,
      movies: specialMovies,
    });
  } catch (error) {
    console.error("Error fetching movie list:", error);
    res.status(500).json({success: false, error: error.message});
  }
});

/**
 * Processes a batch of movies to fetch trailers and updates the list.
 *
 * @param {string} country - The country code for the movies.
 * @param {Array} moviesData - The list of movies to process.
 * @param {number} processedCount - The count of processed movies.
 * @param {number} startTime - The start time of the batch process.
 * @param {boolean} [isSpecial=false] - Whether the movies belong to a special section.
 * @return {Promise<Array>} The updated list of movies.
 */
async function processBatch(country, moviesData, processedCount, startTime, isSpecial = false) {
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

      if (isSpecial) {
        fetchedMovie = await searchSpecialMovieInfoByTid(movie);
      } else {
        fetchedMovie = await searchMovieInfoByTitle(country, movie.localTitle);
      }

      if (fetchedMovie) {
        movie.posterUrl = fetchedMovie.poster_path ? `https://image.tmdb.org/t/p/w600_and_h900_bestv2${fetchedMovie.poster_path}` : movie.posterUrl;
        movie.trailerUrl = fetchedMovie.trailerLink || "";
        movie.country = movie.country ? movie.country : fetchedMovie.origin_country ? fetchedMovie.origin_country[0]: "";
        movie.spec = fetchedMovie.overview ? fetchedMovie.overview : movie.spec ? movie.spec: "";
        movie.releaseDate = fetchedMovie.release_date ? fetchedMovie.release_date : movie.releaseDate? movie.releaseDate : "";
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
 * Test function for fetching and processing movie data from CGV and Lotte.
 * Can be triggered via an HTTP request.
 *
 * @param {Object} req - The request object.
 * @param {Object} res - The response object.
 * @returns {Promise<void>} Sends a JSON response when the function completes.
 */
exports.testFetchMovieListKR = functions.runWith({timeoutSeconds: 540}).https.onRequest(async (req, res) => {
  try {
    const processedCount = 0; // Reset for KR
    const startTime = Date.now();

    const lotteMovies = await fetchMovieListFromLotte();
    const cgvMovies = await fetchMovieListFromCgv(lotteMovies);
    const allMovies = [...lotteMovies, ...cgvMovies];

    console.log(`lotte : ${lotteMovies.length} cgv: ${cgvMovies.length}`);
    const moviesWithTrailer = await processBatch("ko-KR", allMovies, processedCount, startTime);

    await saveMoviesAsJson("kr", moviesWithTrailer);

    const timestamp = new Date().toISOString();
    console.log(`Success: [${timestamp}] Country: KR, Movie Count: ${moviesWithTrailer.length}`);

    res.status(200).json({
      success: true,
      timestamp,
      country: "KR",
      movieCount: moviesWithTrailer.length,
      movies: moviesWithTrailer,
    });
  } catch (error) {
    console.error("Error fetching movie list:", error);
    res.status(500).json({success: false, error: error.message});
  }
});

/**
 * Test function for fetching and processing movie data from EIGA.
 * Can be triggered via an HTTP request.
 *
 * @param {Object} req - The request object.
 * @param {Object} res - The response object.
 * @returns {Promise<void>} Sends a JSON response when the function completes.
 */
exports.testFetchMovieListJP = functions.runWith({timeoutSeconds: 540}).https.onRequest(async (req, res) => {
  try {
    const processedCount = 0;
    const startTime = Date.now();

    const runningMovies = await fetchRunningFromEIGA(false);
    const upcomingMovies = await fetchUpcomingFromEIGA(false);
    const allMovies = [...runningMovies, ...upcomingMovies];

    const moviesWithTrailer = await processBatch("ja-JP", allMovies, processedCount, startTime);

    await saveMoviesAsJson("jp", moviesWithTrailer);

    const timestamp = new Date().toISOString();
    console.log(`Success: [${timestamp}] Country: JP, Movie Count: ${moviesWithTrailer.length}`);

    res.status(200).json({
      success: true,
      timestamp,
      country: "JP",
      movieCount: moviesWithTrailer.length,
      movies: moviesWithTrailer,
    });
  } catch (error) {
    console.error("Error fetching movie list:", error);
    res.status(500).json({success: false, error: error.message});
  }
});

/**
 * Test function for fetching and processing movie data from Cineplex.
 * Can be triggered via an HTTP request.
 *
 * @param {Object} req - The request object.
 * @param {Object} res - The response object.
 * @returns {Promise<void>} Sends a JSON response when the function completes.
 */
exports.testFetchMovieListCA = functions.runWith({timeoutSeconds: 540}).https.onRequest(async (req, res) => {
  try {
    const processedCount = 0;
    const startTime = Date.now();

    const allMovies = await fetchMovieListFromCineplex();

    console.log(`Cineplex Movies: ${allMovies.length}`);
    const moviesWithTrailer = await processBatch("en-CA", allMovies, processedCount, startTime);

    await saveMoviesAsJson("ca", moviesWithTrailer);

    const timestamp = new Date().toISOString();
    console.log(`Success: [${timestamp}] Country: CA, Movie Count: ${moviesWithTrailer.length}`);

    res.status(200).json({
      success: true,
      timestamp,
      country: "CA",
      movieCount: moviesWithTrailer.length,
      movies: moviesWithTrailer,
    });
  } catch (error) {
    console.error("Error fetching movie list:", error);
    res.status(500).json({success: false, error: error.message});
  }
});

/**
 * Test function for fetching and processing movie data from ShowTime.
 * Can be triggered via an HTTP request.
 *
 * @param {Object} req - The request object.
 * @param {Object} res - The response object.
 * @returns {Promise<void>} Sends a JSON response when the function completes.
 */
exports.testFetchMovieListTW = functions.runWith({timeoutSeconds: 540}).https.onRequest(async (req, res) => {
  try {
    const allMovies = await fetchMovieListFromShowTime();

    console.log(`ShowTime Movies: ${allMovies.length}`);

    await saveMoviesAsJson("tw", allMovies);

    const timestamp = new Date().toISOString();
    console.log(`Success: [${timestamp}] Country: TW, Movie Count: ${allMovies.length}`);

    res.status(200).json({
      success: true,
      timestamp,
      country: "TW",
      movieCount: allMovies.length,
      movies: allMovies,
    });
  } catch (error) {
    console.error("Error fetching movie list:", error);
    res.status(500).json({success: false, error: error.message});
  }
});

/**
 * Test function for fetching and processing movie data from UGA.
 * Can be triggered via an HTTP request.
 *
 * @param {Object} req - The request object.
 * @param {Object} res - The response object.
 * @returns {Promise<void>} Sends a JSON response when the function completes.
 */
exports.testFetchMovieListFR = functions.runWith({timeoutSeconds: 540}).https.onRequest(async (req, res) => {
  try {
    const processedCount = 0;
    const startTime = Date.now();

    const allMovies = await fetchMovieListFromUga();

    console.log(`UGA Movies: ${allMovies.length}`);
    const moviesWithTrailer = await processBatch("fr-FR", allMovies, processedCount, startTime);

    await saveMoviesAsJson("fr", moviesWithTrailer);

    const timestamp = new Date().toISOString();
    console.log(`Success: [${timestamp}] Country: FR, Movie Count: ${moviesWithTrailer.length}`);

    res.status(200).json({
      success: true,
      timestamp,
      country: "FR",
      movieCount: moviesWithTrailer.length,
      movies: moviesWithTrailer,
    });
  } catch (error) {
    console.error("Error fetching movie list:", error);
    res.status(500).json({success: false, error: error.message});
  }
});

/**
 * Test function for fetching and processing movie data from Traumpalast.
 * Can be triggered via an HTTP request.
 *
 * @param {Object} req - The request object.
 * @param {Object} res - The response object.
 * @returns {Promise<void>} Sends a JSON response when the function completes.
 */
exports.testFetchMovieListDE = functions.runWith({timeoutSeconds: 540}).https.onRequest(async (req, res) => {
  try {
    const processedCount = 0;
    const startTime = Date.now();

    const allMovies = await fetchMovieListFromTraumpalast();

    console.log(`Traumpalast Movies: ${allMovies.length}`);
    const moviesWithTrailer = await processBatch("de-DE", allMovies, processedCount, startTime);

    await saveMoviesAsJson("de", moviesWithTrailer);

    const timestamp = new Date().toISOString();
    console.log(`Success: [${timestamp}] Country: DE, Movie Count: ${moviesWithTrailer.length}`);

    res.status(200).json({
      success: true,
      timestamp,
      country: "DE",
      movieCount: moviesWithTrailer.length,
      movies: moviesWithTrailer,
    });
  } catch (error) {
    console.error("Error fetching movie list:", error);
    res.status(500).json({success: false, error: error.message});
  }
});

/**
 * Test function for fetching and processing movie data from TMDB (US).
 * Can be triggered via an HTTP request.
 *
 * @param {Object} req - The request object.
 * @param {Object} res - The response object.
 * @returns {Promise<void>} Sends a JSON response when the function completes.
 */
exports.testFetchMovieListUS = functions.runWith({timeoutSeconds: 540}).https.onRequest(async (req, res) => {
  try {
    const processedCount = 0;
    const startTime = Date.now();

    const allMovies = await fetchMovieListFromTMDBByUS();

    console.log(`TMDB US Movies: ${allMovies.length}`);
    const moviesWithTrailer = await processBatch("en-US", allMovies, processedCount, startTime, true);

    await saveMoviesAsJson("us", moviesWithTrailer);

    const timestamp = new Date().toISOString();
    console.log(`Success: [${timestamp}] Country: US, Movie Count: ${moviesWithTrailer.length}`);

    res.status(200).json({
      success: true,
      timestamp,
      country: "US",
      movieCount: moviesWithTrailer.length,
      movies: moviesWithTrailer,
    });
  } catch (error) {
    console.error("Error fetching movie list:", error);
    res.status(500).json({success: false, error: error.message});
  }
});

/**
 * Reads a movie list JSON file from Firebase Storage based on the provided country code.
 * Can be triggered via an HTTP request with a country query parameter.
 *
 * @param {Object} req - The request object.
 * @param {Object} res - The response object.
 * @returns {Promise<void>} Sends a JSON response with the movie list when the function completes.
 */
exports.readMovieListByCountry = functions.https.onRequest(async (req, res) => {
  const country = req.query.country;

  if (!country) {
    return res.status(400).json({success: false, message: "Country code is required."});
  }

  try {
    const bucket = admin.storage().bucket();
    const fileName = `movies_${country.toLowerCase()}.json`; // Construct the file name based on the country code
    const file = bucket.file(fileName);

    const exists = await file.exists();
    if (!exists[0]) {
      return res.status(404).json({success: false, message: "File not found for the specified country code."});
    }

    const fileContents = await file.download();
    const movies = JSON.parse(fileContents.toString());

    res.status(200).json({
      success: true,
      country: country.toUpperCase(),
      movieCount: movies.movies.length,
      timestamp: movies.timestamp,
      movies: movies.movies,
    });
  } catch (error) {
    console.error("Error reading movie list:", error);
    res.status(500).json({success: false, error: error.message});
  }
});
