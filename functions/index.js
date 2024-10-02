/* eslint-disable max-len */
const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");
const {fetchMovieListFromCgv, fetchMovieListFromLotte} = require("./movie_kr");
const {fetchRunningFromEIGA, fetchUpcomingFromEIGA} = require("./movie_jp");
const {fetchMovieListFromCineplex} = require("./movie_ca");
const {fetchMovieListFromShowTime} = require("./movie_tw");
const {fetchMovieListFromUga} = require("./movie_fr");
const {fetchMovieListFromTraumpalast} = require("./movie_de");
const {fetchMovieListFromTMDBByUS} = require("./movie_us");
const {fetchMovieListFromSf} = require("./movie_th");
const {fetchMovieListFromTMDBByAU} = require("./movie_au");
const {fetchMovieListFromKinepolis} = require("./movie_es");
const {fetchMovieListFromInox} = require("./movie_in");
const {fetchMovieListFromTMDBByCN} = require("./movie_cn");
const {fetchMovieInSpecialSection} = require("./movie_special");
const {fetchQuotesInSpecialSection} = require("./quote_special");
const {processBatch, saveMoviesAsJson, saveQuotesAsJson} = require("./utils");

admin.initializeApp();

/**
 * Fetches movies from CGV and Lotte, processes trailers, and saves the result.
 * Scheduled to run every Monday at 09:00 AM KST.
 *
 * @returns {Promise<null>} Returns null when the function completes.
 */
exports.fetchMovieListKR = functions
    .runWith({timeoutSeconds: 540})
    .pubsub
    .schedule("0 9 * * 1")
    .timeZone("America/Toronto") // Adjust if the timezone should be KST
    .onRun(async () => {
      const processedCount = 0;
      const startTime = Date.now();

      const lotteMovies = await fetchMovieListFromLotte();
      const cgvMovies = await fetchMovieListFromCgv(lotteMovies);
      const allMovies = [...lotteMovies, ...cgvMovies];

      const moviesWithDetails = await processBatch("ko-KR", allMovies, processedCount, startTime);

      await saveMoviesAsJson("kr", moviesWithDetails);

      const timestamp = new Date().toISOString();
      console.log(`Success: [${timestamp}] Country: KR, Movie Count: ${moviesWithDetails.length}`);

      return null;
    });

/**
 * Fetches movies from EIGA, processes trailers, and saves the result.
 * Scheduled to run every Tuesday at 09:00 AM JST.
 *
 * @returns {Promise<null>} Returns null when the function completes.
 */
exports.fetchMovieListJP = functions
    .runWith({timeoutSeconds: 540})
    .pubsub
    .schedule("0 9 * * 2")
    .timeZone("America/Toronto") // Adjust if the timezone should be JST
    .onRun(async () => {
      const processedCount = 0;
      const startTime = Date.now();

      const runningMovies = await fetchRunningFromEIGA(false);
      const upcomingMovies = await fetchUpcomingFromEIGA(false);
      const allMovies = [...runningMovies, ...upcomingMovies];

      const moviesWithTrailer = await processBatch("ja-JP", allMovies, processedCount, startTime);

      await saveMoviesAsJson("jp", moviesWithTrailer);

      const timestamp = new Date().toISOString();
      console.log(`Success: [${timestamp}] Country: JP, Movie Count: ${moviesWithTrailer.length}`);

      return null;
    });

/**
 * Fetches movies from Cineplex, processes trailers, and saves the result.
 * Scheduled to run every Wednesday at 09:00 AM EST.
 *
 * @returns {Promise<null>} Returns null when the function completes.
 */
exports.fetchMovieListCA = functions
    .runWith({timeoutSeconds: 540})
    .pubsub
    .schedule("0 9 * * 3")
    .timeZone("America/Toronto")
    .onRun(async () => {
      const processedCount = 0;
      const startTime = Date.now();

      const allMovies = await fetchMovieListFromCineplex();

      const moviesWithDetails = await processBatch("en-CA", allMovies, processedCount, startTime);

      await saveMoviesAsJson("ca", moviesWithDetails);

      const timestamp = new Date().toISOString();
      console.log(`Success: [${timestamp}] Country: CA, Movie Count: ${moviesWithDetails.length}`);

      return null;
    });

/**
 * Fetches movies from ShowTime, processes trailers, and saves the result.
 * Scheduled to run every Thursday at 09:00 AM CST.
 *
 * @returns {Promise<null>} Returns null when the function completes.
 */
exports.fetchMovieListTW = functions
    .runWith({timeoutSeconds: 540})
    .pubsub
    .schedule("0 9 * * 4")
    .timeZone("America/Toronto") // Adjust if the timezone should be CST
    .onRun(async () => {
      const allMovies = await fetchMovieListFromShowTime();

      await saveMoviesAsJson("tw", allMovies);

      const timestamp = new Date().toISOString();
      console.log(`Success: [${timestamp}] Country: TW, Movie Count: ${allMovies.length}`);

      return null;
    });

/**
 * Fetches movies from UGA, processes trailers, and saves the result.
 * Scheduled to run every Friday at 09:00 AM CET.
 *
 * @returns {Promise<null>} Returns null when the function completes.
 */
exports.fetchMovieListFR = functions
    .runWith({timeoutSeconds: 540})
    .pubsub
    .schedule("0 9 * * 5")
    .timeZone("America/Toronto") // Adjust if the timezone should be CET
    .onRun(async () => {
      const processedCount = 0;
      const startTime = Date.now();

      const allMovies = await fetchMovieListFromUga();

      const moviesWithDetails = await processBatch("fr-FR", allMovies, processedCount, startTime);

      await saveMoviesAsJson("fr", moviesWithDetails);

      const timestamp = new Date().toISOString();
      console.log(`Success: [${timestamp}] Country: FR, Movie Count: ${moviesWithDetails.length}`);

      return null;
    });

/**
 * Fetches movies from Traumpalast, processes trailers, and saves the result.
 * Scheduled to run every Saturday at 09:00 AM CET.
 *
 * @returns {Promise<null>} Returns null when the function completes.
 */
exports.fetchMovieListDE = functions
    .runWith({timeoutSeconds: 540})
    .pubsub
    .schedule("0 9 * * 6")
    .timeZone("America/Toronto") // Adjust if the timezone should be CET
    .onRun(async () => {
      const processedCount = 0;
      const startTime = Date.now();

      const allMovies = await fetchMovieListFromTraumpalast();

      const moviesWithDetails = await processBatch("de-DE", allMovies, processedCount, startTime);

      await saveMoviesAsJson("de", moviesWithDetails);

      const timestamp = new Date().toISOString();
      console.log(`Success: [${timestamp}] Country: DE, Movie Count: ${moviesWithDetails.length}`);

      return null;
    });

/**
 * Fetches movies from TMDB by US region, processes trailers, and saves the result.
 * Scheduled to run every Sunday at 09:00 AM EST.
 *
 * @returns {Promise<null>} Returns null when the function completes.
 */
exports.fetchMovieListUS = functions
    .runWith({timeoutSeconds: 540})
    .pubsub
    .schedule("0 7 * * 3")
    .timeZone("America/Toronto")
    .onRun(async () => {
      const processedCount = 0;
      const startTime = Date.now();

      const allMovies = await fetchMovieListFromTMDBByUS();

      const moviesWithDetails = await processBatch("en-US", allMovies, processedCount, startTime, true);

      await saveMoviesAsJson("us", moviesWithDetails);

      const timestamp = new Date().toISOString();
      console.log(`Success: [${timestamp}] Country: US, Movie Count: ${moviesWithDetails.length}`);

      return null;
    });

/**
 * Fetches movies from Sf by TH region, processes trailers, and saves the result.
 * Scheduled to run every Sunday at 5:00 AM EST.
 *
 * @returns {Promise<null>} Returns null when the function completes.
 */
exports.fetchMovieListTH = functions
    .runWith({timeoutSeconds: 540})
    .pubsub
    .schedule("0 5 * * 7")
    .timeZone("America/Toronto")
    .onRun(async () => {
      const processedCount = 0;
      const startTime = Date.now();

      const allMovies = await fetchMovieListFromSf();

      const moviesWithDetails = await processBatch("th-TH", allMovies, processedCount, startTime, true);

      await saveMoviesAsJson("th", moviesWithDetails);

      const timestamp = new Date().toISOString();
      console.log(`Success: [${timestamp}] Country: TH, Movie Count: ${moviesWithDetails.length}`);

      return null;
    });

/**
 * Fetches movies from Event Cinema by AU region, processes trailers, and saves the result.
 * Scheduled to run every Sunday at 2:00 AM EST.
 *
 * @returns {Promise<null>} Returns null when the function completes.
 */
exports.fetchMovieListAU = functions
    .runWith({timeoutSeconds: 540})
    .pubsub
    .schedule("0 2 * * 7")
    .timeZone("America/Toronto")
    .onRun(async () => {
      const processedCount = 0;
      const startTime = Date.now();

      const allMovies = await fetchMovieListFromTMDBByAU();

      const moviesWithDetails = await processBatch("en-AU", allMovies, processedCount, startTime, true);

      await saveMoviesAsJson("au", moviesWithDetails);

      const timestamp = new Date().toISOString();
      console.log(`Success: [${timestamp}] Country: AU, Movie Count: ${moviesWithDetails.length}`);

      return null;
    });

/**
 * Fetches movies from Kinepolis, processes trailers, and saves the result.
 * Scheduled to run every Thursday at 09:00 AM CST.
 *
 * @returns {Promise<null>} Returns null when the function completes.
 */
exports.fetchMovieListES = functions
    .runWith({timeoutSeconds: 540})
    .pubsub
    .schedule("0 5 * * 4")
    .timeZone("America/Toronto") // Adjust if the timezone should be CST
    .onRun(async () => {
      const allMovies = await fetchMovieListFromKinepolis();

      await saveMoviesAsJson("es", allMovies);

      const timestamp = new Date().toISOString();
      console.log(`Success: [${timestamp}] Country: ES, Movie Count: ${allMovies.length}`);

      return null;
    });

/**
 * Fetches movies from Inox, processes trailers, and saves the result.
 * Scheduled to run every Thursday at 09:00 AM CST.
 *
 * @returns {Promise<null>} Returns null when the function completes.
 */
exports.fetchMovieListIN = functions
    .runWith({timeoutSeconds: 540})
    .pubsub
    .schedule("0 3 * * 4")
    .timeZone("America/Toronto") // Adjust if the timezone should be CST
    .onRun(async () => {
      const allMovies = await fetchMovieListFromInox();

      await saveMoviesAsJson("in", allMovies);

      const timestamp = new Date().toISOString();
      console.log(`Success: [${timestamp}] Country: IN, Movie Count: ${allMovies.length}`);

      return null;
    });

/**
 * Fetches movies from Wanda, processes trailers, and saves the result.
 * Scheduled to run every Tuesday at 11:00 AM JST.
 *
 * @returns {Promise<null>} Returns null when the function completes.
 */
exports.fetchMovieListCN = functions
    .runWith({timeoutSeconds: 540})
    .pubsub
    .schedule("0 11 * * 4")
    .timeZone("America/Toronto") // Adjust if the timezone should be JST
    .onRun(async () => {
      const processedCount = 0;
      const startTime = Date.now();

      const allMovies = await fetchMovieListFromTMDBByCN();

      const moviesWithDetails = await processBatch("zh-CN", allMovies, processedCount, startTime, true);

      await saveMoviesAsJson("cn", moviesWithDetails);

      const timestamp = new Date().toISOString();
      console.log(`Success: [${timestamp}] Country: cn, Movie Count: ${moviesWithDetails.length}`);

      return null;
    });

/**
 * Fetches movies in the special section by director, processes trailers, and saves the result.
 * Scheduled to run every First day of the month at 1:00 AM EST.
 *
 * @returns {Promise<void>} Returns null when the function completes.
 */
exports.fetchMovieListSpecial = functions
    .runWith({timeoutSeconds: 540})
    .pubsub
    .schedule("0 0 1 * *")
    .timeZone("America/Toronto")
    .onRun(async () => {
      const processedCount = 0;
      const startTime = Date.now();

      const specialMovies = await fetchMovieInSpecialSection();

      const moviesWithTrailer = await processBatch("en-US", specialMovies, processedCount, startTime, true);

      await saveMoviesAsJson("special", moviesWithTrailer);

      const timestamp = new Date().toISOString();
      console.log(`Success: [${timestamp}] Country: Special, Movie Count: ${moviesWithTrailer.length}`);

      return null;
    });

/**
 * Fetches quotes in the special section
 * Scheduled to run every First day of the 6 month at 1:00 AM EST.
 *
 * @returns {Promise<void>} Returns null when the function completes.
 */
exports.fetchQuoteListSpecial = functions
    .runWith({timeoutSeconds: 540})
    .pubsub
    .schedule("0 1 1 */6 *")
    .timeZone("America/Toronto")
    .onRun(async () => {
      const specialQuotes = await fetchQuotesInSpecialSection();

      await saveQuotesAsJson("special", specialQuotes);

      const timestamp = new Date().toISOString();
      console.log(`Success: [${timestamp}] Country: Special, Quote Count: ${specialQuotes.length}`);

      return null;
    });

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
    const processedCount = 0;
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
 * Test function for fetching and processing movie data from TMDB (TH).
 * Can be triggered via an HTTP request.
 *
 * @param {Object} req - The request object.
 * @param {Object} res - The response object.
 * @returns {Promise<void>} Sends a JSON response when the function completes.
 */
exports.testFetchMovieListTH = functions.runWith({timeoutSeconds: 540}).https.onRequest(async (req, res) => {
  try {
    const processedCount = 0;
    const startTime = Date.now();

    const allMovies = await fetchMovieListFromSf();

    console.log(`SFCinema Movies: ${allMovies.length}`);
    const moviesWithTrailer = await processBatch("th-TH", allMovies, processedCount, startTime, true);

    await saveMoviesAsJson("th", moviesWithTrailer);

    const timestamp = new Date().toISOString();
    console.log(`Success: [${timestamp}] Country: TH, Movie Count: ${moviesWithTrailer.length}`);

    res.status(200).json({
      success: true,
      timestamp,
      country: "TH",
      movieCount: moviesWithTrailer.length,
      movies: moviesWithTrailer,
    });
  } catch (error) {
    console.error("Error fetching movie list:", error);
    res.status(500).json({success: false, error: error.message});
  }
});

/**
 * Test function for fetching and processing movie data from Event Cinema.
 * Can be triggered via an HTTP request.
 *
 * @param {Object} req - The request object.
 * @param {Object} res - The response object.
 * @returns {Promise<void>} Sends a JSON response when the function completes.
 */
exports.testFetchMovieListAU = functions.runWith({timeoutSeconds: 540}).https.onRequest(async (req, res) => {
  try {
    const processedCount = 0;
    const startTime = Date.now();

    const allMovies = await fetchMovieListFromTMDBByAU();

    console.log(`TMDB AU Movies: ${allMovies.length}`);
    const moviesWithTrailer = await processBatch("en-AU", allMovies, processedCount, startTime, true);

    await saveMoviesAsJson("au", moviesWithTrailer);

    const timestamp = new Date().toISOString();
    console.log(`Success: [${timestamp}] Country: AU, Movie Count: ${moviesWithTrailer.length}`);

    res.status(200).json({
      success: true,
      timestamp,
      country: "AU",
      movieCount: moviesWithTrailer.length,
      movies: moviesWithTrailer,
    });
  } catch (error) {
    console.error("Error fetching movie list:", error);
    res.status(500).json({success: false, error: error.message});
  }
});

/**
 * Test function for fetching and processing movie data from Kinepolis.
 * Can be triggered via an HTTP request.
 *
 * @param {Object} req - The request object.
 * @param {Object} res - The response object.
 * @returns {Promise<void>} Sends a JSON response when the function completes.
 */
exports.testFetchMovieListES = functions.runWith({timeoutSeconds: 540}).https.onRequest(async (req, res) => {
  try {
    const allMovies = await fetchMovieListFromKinepolis();

    await saveMoviesAsJson("es", allMovies);

    const timestamp = new Date().toISOString();
    console.log(`Success: [${timestamp}] Country: ES, Movie Count: ${allMovies.length}`);

    res.status(200).json({
      success: true,
      timestamp,
      country: "ES",
      movieCount: allMovies.length,
      movies: allMovies,
    });
  } catch (error) {
    console.error("Error fetching movie list:", error);
    res.status(500).json({success: false, error: error.message});
  }
});

/**
 * Test function for fetching and processing movie data from Inox.
 * Can be triggered via an HTTP request.
 *
 * @param {Object} req - The request object.
 * @param {Object} res - The response object.
 * @returns {Promise<void>} Sends a JSON response when the function completes.
 */
exports.testFetchMovieListIN = functions.runWith({timeoutSeconds: 540}).https.onRequest(async (req, res) => {
  try {
    const allMovies = await fetchMovieListFromInox();

    await saveMoviesAsJson("in", allMovies);

    const timestamp = new Date().toISOString();
    console.log(`Success: [${timestamp}] Country: IN, Movie Count: ${allMovies.length}`);

    res.status(200).json({
      success: true,
      timestamp,
      country: "IN",
      movieCount: allMovies.length,
      movies: allMovies,
    });
  } catch (error) {
    console.error("Error fetching movie list:", error);
    res.status(500).json({success: false, error: error.message});
  }
});

/**
 * Test function for fetching and processing movie data from Wanda.
 * Can be triggered via an HTTP request.
 *
 * @param {Object} req - The request object.
 * @param {Object} res - The response object.
 * @returns {Promise<void>} Sends a JSON response when the function completes.
 */
exports.testFetchMovieListCN = functions.runWith({timeoutSeconds: 540}).https.onRequest(async (req, res) => {
  try {
    const processedCount = 0;
    const startTime = Date.now();

    const allMovies = await fetchMovieListFromTMDBByCN();

    console.log(`TMDB CN Movies: ${allMovies.length}`);
    const moviesWithTrailer = await processBatch("zh-CN", allMovies, processedCount, startTime, true);

    await saveMoviesAsJson("cn", moviesWithTrailer);

    const timestamp = new Date().toISOString();
    console.log(`Success: [${timestamp}] Country: CN, Movie Count: ${moviesWithTrailer.length}`);

    res.status(200).json({
      success: true,
      timestamp,
      country: "CN",
      movieCount: moviesWithTrailer.length,
      movies: moviesWithTrailer,
    });
  } catch (error) {
    console.error("Error fetching movie list:", error);
    res.status(500).json({success: false, error: error.message});
  }
});

/**
 * Test function for fetching and processing movie data from Special Excel.
 * Can be triggered via an HTTP request.
 *
 * @param {Object} req - The request object.
 * @param {Object} res - The response object.
 * @returns {Promise<void>} Sends a JSON response when the function completes.
 */
exports.testFetchMovieListSpecial = functions.runWith({timeoutSeconds: 540}).https.onRequest(async (req, res) => {
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
 * Test function for fetching and processing quote data from Special Excel.
 * Can be triggered via an HTTP request.
 *
 * @param {Object} req - The request object.
 * @param {Object} res - The response object.
 * @returns {Promise<void>} Sends a JSON response when the function completes.
 */
exports.testFetchQuoteListSpecial = functions.runWith({timeoutSeconds: 540}).https.onRequest(async (req, res) => {
  try {
    const specialQuotes = await fetchQuotesInSpecialSection();

    await saveQuotesAsJson("special", specialQuotes);

    const timestamp = new Date().toISOString();
    console.log(`Success: [${timestamp}] Country: Special, Quote Count: ${specialQuotes.length}`);

    res.status(200).json({
      success: true,
      timestamp,
      country: "Special",
      quoteCount: specialQuotes.length,
      quotes: specialQuotes,
    });
  } catch (error) {
    console.error("Error fetching quote list:", error);
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
