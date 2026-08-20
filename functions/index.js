/* eslint-disable max-len */
const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");
const {fetchMovieListFromCgv, fetchMovieListFromLotte} = require("./countries/movie_kr");
const {fetchRunningFromEIGA} = require("./countries/movie_jp");
const {fetchMovieListFromCineplex} = require("./countries/movie_ca");
const {fetchMovieListFromShowTime} = require("./countries/movie_tw");
const {fetchMovieListFromUga} = require("./countries/movie_fr");
const {fetchMovieListFromTMDBByDE} = require("./countries/movie_de");
const {fetchMovieListFromTMDBByUS} = require("./countries/movie_us");
const {fetchMovieListFromTMDBByTH} = require("./countries/movie_th");
const {fetchMovieListFromTMDBByAU} = require("./countries/movie_au");
const {fetchMovieListFromTMDBByES} = require("./countries/movie_es_tmdb");
const {fetchMovieListFromTMDBByIN} = require("./countries/movie_in_tmdb");
const {fetchRunningFromDouban, fetchUpcomingFromDouban} = require("./countries/movie_cn");
const {fetchMovieInSpecialSection} = require("./features/special/movies");
const {fetchQuotesInSpecialSection} = require("./features/quote/special");
const {fetchMovieListFromMojo} = require("./features/box_office/usa");
const {fetchMovieListFromKobis} = require("./features/box_office/kr");
const {processBatch, saveMoviesAsJson, saveQuotesAsJson, updatePromotionUrl, processBatchForSpecial, reuseExistingSpecialMovies, selectNextSpecialPeriod} = require("./services/utils");
const {publishSheetMovies, writeMoviesToSheet} = require("./services/movie_publisher");
const {readSpecialDataSheet} = require("./services/movie_sheet");

admin.initializeApp();

const cors = require("cors");
const corsHandler = cors({origin: true});
const movieRuntimeOptions = {
  timeoutSeconds: 540,
  secrets: ["TMDB_ACCESS_TOKEN", "YOUTUBE_API_KEY"],
};
const kobisRuntimeOptions = {
  ...movieRuntimeOptions,
  secrets: [...movieRuntimeOptions.secrets, "KOBIS_API_KEY"],
};
const DEFAULT_TEST_LIMIT = 10;
const MAX_TEST_LIMIT = 20;
const SHEET_SYNC_COUNTRIES = new Set([
  "kr", "jp", "ca", "tw", "fr", "de", "us", "th", "au", "es", "in", "cn",
  "special", "box_office", "box_office_kr",
]);

/**
 * Creates a scheduled Sheet-to-Storage publisher.
 * @param {string} country Storage country/category key.
 * @param {string} schedule Cloud Scheduler cron expression.
 * @return {Function} Firebase scheduled function.
 */
function createScheduledStore(country, schedule) {
  return functions.runWith({timeoutSeconds: 540})
      .pubsub
      .schedule(schedule)
      .timeZone("America/Toronto")
      .onRun(async () => {
        const published = await publishSheetMovies(country);
        console.log(`Stored ${published.movies.length} ${country} movies from Sheet.`);
        return null;
      });
}

/**
 * Creates a manually invoked Sheet-to-Storage test publisher.
 * @param {string} country Storage country/category key.
 * @return {Function} Firebase HTTPS function.
 */
function createTestStore(country) {
  return functions.runWith({timeoutSeconds: 540}).https.onRequest((req, res) => {
    corsHandler(req, res, async () => {
      try {
        const published = await publishSheetMovies(country);
        res.status(200).json({
          success: true,
          country,
          timestamp: published.timestamp,
          movieCount: published.movies.length,
        });
      } catch (error) {
        console.error(`Error storing ${country} Sheet:`, error);
        res.status(500).json({success: false, error: error.message});
      }
    });
  });
}

/**
 * Restricts test endpoints so they cannot consume an entire API quota.
 * @param {Object} req HTTP request containing an optional limit query.
 * @param {Array} items Items returned by the source crawler.
 * @param {boolean} allowUnlimited Whether limit=all may bypass the test cap.
 * @return {Array} At most the requested number of test items.
 */
function limitTestItems(req, items, allowUnlimited = false) {
  if (allowUnlimited && String(req.query.limit).toLowerCase() === "all") {
    return items;
  }
  const requestedLimit = Number.parseInt(req.query.limit, 10);
  const limit = Number.isInteger(requestedLimit) ?
    Math.min(Math.max(requestedLimit, 1), MAX_TEST_LIMIT) : DEFAULT_TEST_LIMIT;
  return items.slice(0, limit);
}

/**
 * Returns a small diagnostic payload without exposing raw TMDB responses.
 * @param {Array} movies Processed movies.
 * @return {Array} Compact diagnostic movie objects.
 */
function buildTestMoviePreview(movies) {
  return movies.map((movie) => ({
    id: movie.id || "",
    tid: movie.tid || movie.tmdbId || "",
    title: movie.title || movie.localTitle || "",
    posterUrl: movie.posterUrl || "",
    trailerUrl: movie.trailerUrl || "",
    releaseDate: movie.releaseDate || "",
    source: movie.source || "",
  }));
}

/**
 * Fetches movies from CGV and Lotte, processes trailers, and saves the result.
 * Scheduled to run every Monday at 09:00 AM KST.
 *
 * @returns {Promise<null>} Returns null when the function completes.
 */
exports.fetchMovieListKR = functions
    .runWith(movieRuntimeOptions)
    .pubsub
    .schedule("0 3 * * 1")
    .timeZone("America/Toronto") // Adjust if the timezone should be KST
    .onRun(async () => {
      const processedCount = 0;
      const startTime = Date.now();

      const lotteMovies = await fetchMovieListFromLotte();
      const cgvMovies = await fetchMovieListFromCgv(lotteMovies);
      const allMovies = [...lotteMovies, ...cgvMovies];

      const moviesWithDetails = await processBatch("ko-KR", allMovies, processedCount, startTime);

      await writeMoviesToSheet("kr", moviesWithDetails);

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
    .runWith(movieRuntimeOptions)
    .pubsub
    .schedule("0 3 * * 2")
    .timeZone("America/Toronto") // Adjust if the timezone should be JST
    .onRun(async () => {
      const processedCount = 0;
      const startTime = Date.now();

      const runningMovies = await fetchRunningFromEIGA();
      const allMovies = [...runningMovies];

      const moviesWithTrailer = await processBatch("ja-JP", allMovies, processedCount, startTime);

      await writeMoviesToSheet("jp", moviesWithTrailer);

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
    .runWith(movieRuntimeOptions)
    .pubsub
    .schedule("0 4 * * 3")
    .timeZone("America/Toronto")
    .onRun(async () => {
      const processedCount = 0;
      const startTime = Date.now();

      const allMovies = await fetchMovieListFromCineplex();

      const moviesWithDetails = await processBatch("en-CA", allMovies, processedCount, startTime);

      await writeMoviesToSheet("ca", moviesWithDetails);

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
    .runWith(movieRuntimeOptions)
    .pubsub
    .schedule("0 5 * * 4")
    .timeZone("America/Toronto") // Adjust if the timezone should be CST
    .onRun(async () => {
      const processedCount = 0;
      const startTime = Date.now();
      const allMovies = await fetchMovieListFromShowTime();
      const moviesWithDetails = await processBatch("zh-TW", allMovies, processedCount, startTime);

      await writeMoviesToSheet("tw", moviesWithDetails);

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
    .runWith(movieRuntimeOptions)
    .pubsub
    .schedule("0 4 * * 5")
    .timeZone("America/Toronto") // Adjust if the timezone should be CET
    .onRun(async () => {
      const processedCount = 0;
      const startTime = Date.now();

      const allMovies = await fetchMovieListFromUga();

      const moviesWithDetails = await processBatch("fr-FR", allMovies, processedCount, startTime);

      await writeMoviesToSheet("fr", moviesWithDetails);

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
    .runWith(movieRuntimeOptions)
    .pubsub
    .schedule("0 3 * * 6")
    .timeZone("America/Toronto") // Adjust if the timezone should be CET
    .onRun(async () => {
      const processedCount = 0;
      const startTime = Date.now();

      const allMovies = await fetchMovieListFromTMDBByDE();

      const moviesWithDetails = await processBatch("de-DE", allMovies, processedCount, startTime, true);

      await writeMoviesToSheet("de", moviesWithDetails);

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
    .runWith(movieRuntimeOptions)
    .pubsub
    .schedule("0 3 * * 3")
    .timeZone("America/Toronto")
    .onRun(async () => {
      const processedCount = 0;
      const startTime = Date.now();

      const allMovies = await fetchMovieListFromTMDBByUS();

      const moviesWithDetails = await processBatch("en-US", allMovies, processedCount, startTime, true);

      await writeMoviesToSheet("us", moviesWithDetails);

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
    .runWith(movieRuntimeOptions)
    .pubsub
    .schedule("0 4 * * 7")
    .timeZone("America/Toronto")
    .onRun(async () => {
      const processedCount = 0;
      const startTime = Date.now();

      const allMovies = await fetchMovieListFromTMDBByTH();

      const moviesWithDetails = await processBatch("th-TH", allMovies, processedCount, startTime, true);

      await writeMoviesToSheet("th", moviesWithDetails);

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
    .runWith(movieRuntimeOptions)
    .pubsub
    .schedule("0 3 * * 7")
    .timeZone("America/Toronto")
    .onRun(async () => {
      const processedCount = 0;
      const startTime = Date.now();

      const allMovies = await fetchMovieListFromTMDBByAU();

      const moviesWithDetails = await processBatch("en-AU", allMovies, processedCount, startTime, true);

      await writeMoviesToSheet("au", moviesWithDetails);

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
    .runWith(movieRuntimeOptions)
    .pubsub
    .schedule("0 4 * * 4")
    .timeZone("America/Toronto") // Adjust if the timezone should be CST
    .onRun(async () => {
      const processedCount = 0;
      const startTime = Date.now();

      const allMovies = await fetchMovieListFromTMDBByES();

      const moviesWithDetails = await processBatch("es-ES", allMovies, processedCount, startTime, true);

      await writeMoviesToSheet("es", moviesWithDetails);

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
    .runWith(movieRuntimeOptions)
    .pubsub
    .schedule("0 3 * * 4")
    .timeZone("America/Toronto") // Adjust if the timezone should be CST
    .onRun(async () => {
      const processedCount = 0;
      const startTime = Date.now();

      const allMovies = await fetchMovieListFromTMDBByIN();

      const moviesWithDetails = await processBatch("hi-IN", allMovies, processedCount, startTime, true);

      await writeMoviesToSheet("in", moviesWithDetails);

      const timestamp = new Date().toISOString();
      console.log(`Success: [${timestamp}] Country: IN, Movie Count: ${moviesWithDetails.length}`);

      return null;
    });

/**
 * Fetches movies from Wanda, processes trailers, and saves the result.
 * Scheduled to run every Friday at 11:00 AM JST.
 *
 * @returns {Promise<null>} Returns null when the function completes.
 */
exports.fetchMovieListCN = functions
    .runWith(movieRuntimeOptions)
    .pubsub
    .schedule("0 3 * * 5")
    .timeZone("America/Toronto") // Adjust if the timezone should be JST
    .onRun(async () => {
      const processedCount = 0;
      const startTime = Date.now();

      const runningMovies = await fetchRunningFromDouban();
      const upcomingMovies = await fetchUpcomingFromDouban();
      const allMovies = [...runningMovies, ...upcomingMovies];

      const moviesWithDetails = await processBatch("zh-CN", allMovies, processedCount, startTime);

      await writeMoviesToSheet("cn", moviesWithDetails);

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
    .runWith(movieRuntimeOptions)
    .pubsub
    .schedule("0 0 1 * *")
    .timeZone("America/Toronto")
    .onRun(async () => {
      const processedCount = 0;
      const startTime = Date.now();

      const specialMovies = selectNextSpecialPeriod(reuseExistingSpecialMovies(
          await fetchMovieInSpecialSection(),
          await readSpecialDataSheet(),
      ));

      const moviesWithTrailer = await processBatchForSpecial("en-US", specialMovies, processedCount, startTime);

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
    .runWith(movieRuntimeOptions)
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
 * Fetches movies from Mojo, processes trailers, and saves the result.
 * Scheduled to run every Monday at 07:00 AM CET.
 *
 * @returns {Promise<null>} Returns null when the function completes.
 */
exports.fetchMovieListBoxOffice = functions
    .runWith(movieRuntimeOptions)
    .pubsub
    .schedule("0 5 * * 1")
    .timeZone("America/Toronto") // Adjust if the timezone should be CET
    .onRun(async () => {
      const processedCount = 0;
      const startTime = Date.now();

      const allMovies = await fetchMovieListFromMojo();

      const moviesWithDetails = await processBatch("en-US", allMovies, processedCount, startTime);

      await writeMoviesToSheet("box_office", moviesWithDetails);

      const timestamp = new Date().toISOString();
      console.log(`Success: [${timestamp}] Country: Box-Office-USA, Movie Count: ${moviesWithDetails.length}`);

      return null;
    });

/**
 * Fetches the Korean weekly box office from KOBIS and publishes it.
 * @returns {Promise<null>} Returns null when the function completes.
 */
exports.fetchMovieListBoxOfficeKR = functions
    .runWith(kobisRuntimeOptions)
    .pubsub
    .schedule("0 4 * * 1")
    .timeZone("America/Toronto")
    .onRun(async () => {
      const processedCount = 0;
      const startTime = Date.now();
      const allMovies = await fetchMovieListFromKobis();
      const moviesWithDetails = await processBatch("ko-KR", allMovies, processedCount, startTime);

      await writeMoviesToSheet("box_office_kr", moviesWithDetails);

      const timestamp = new Date().toISOString();
      console.log(`Success: [${timestamp}] Country: Box-Office-KR, Movie Count: ${moviesWithDetails.length}`);
      return null;
    });

// Stores run after Sheet translation formulas have had roughly two hours.
exports.storeMovieListKR = createScheduledStore("kr", "10 5 * * 1");
exports.storeMovieListJP = createScheduledStore("jp", "0 5 * * 2");
exports.storeMovieListCA = createScheduledStore("ca", "0 6 * * 3");
exports.storeMovieListTW = createScheduledStore("tw", "0 7 * * 4");
exports.storeMovieListFR = createScheduledStore("fr", "0 6 * * 5");
exports.storeMovieListDE = createScheduledStore("de", "0 5 * * 6");
exports.storeMovieListUS = createScheduledStore("us", "0 5 * * 3");
exports.storeMovieListTH = createScheduledStore("th", "0 6 * * 7");
exports.storeMovieListAU = createScheduledStore("au", "0 5 * * 7");
exports.storeMovieListES = createScheduledStore("es", "0 6 * * 4");
exports.storeMovieListIN = createScheduledStore("in", "10 5 * * 4");
exports.storeMovieListCN = createScheduledStore("cn", "0 5 * * 5");
exports.storeMovieListBoxOffice = createScheduledStore("box_office", "0 7 * * 1");
exports.storeMovieListBoxOfficeKR = createScheduledStore("box_office_kr", "0 6 * * 1");

/**
 * Test function for fetching and processing movie data from CGV and Lotte.
 * Can be triggered via an HTTP request.
 *
 * @param {Object} req - The request object.
 * @param {Object} res - The response object.
 * @returns {Promise<void>} Sends a JSON response when the function completes.
 */
exports.testFetchMovieListKR = functions.runWith(movieRuntimeOptions).https.onRequest(async (req, res) => {
  try {
    const processedCount = 0;
    const startTime = Date.now();

    const lotteMovies = await fetchMovieListFromLotte();
    const cgvMovies = await fetchMovieListFromCgv(lotteMovies);
    const allMovies = [...lotteMovies, ...cgvMovies];
    const testMovies = limitTestItems(req, allMovies);

    console.log(`lotte: ${lotteMovies.length}, cgv: ${cgvMovies.length}, test limit: ${testMovies.length}`);
    const moviesWithTrailer = await processBatch("ko-KR", testMovies, processedCount, startTime);

    await writeMoviesToSheet("kr", moviesWithTrailer);

    const timestamp = new Date().toISOString();
    console.log(`Success: [${timestamp}] Country: KR, Movie Count: ${moviesWithTrailer.length}`);

    res.status(200).json({
      success: true,
      timestamp,
      country: "KR",
      movieCount: moviesWithTrailer.length,
      movies: buildTestMoviePreview(moviesWithTrailer),
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
exports.testFetchMovieListJP = functions.runWith(movieRuntimeOptions).https.onRequest(async (req, res) => {
  try {
    const processedCount = 0;
    const startTime = Date.now();

    const runningMovies = await fetchRunningFromEIGA();
    const allMovies = [...runningMovies];
    const testMovies = limitTestItems(req, allMovies);

    const moviesWithTrailer = await processBatch("ja-JP", testMovies, processedCount, startTime);

    await writeMoviesToSheet("jp", moviesWithTrailer);

    const timestamp = new Date().toISOString();
    console.log(`Success: [${timestamp}] Country: JP, Movie Count: ${moviesWithTrailer.length}`);

    res.status(200).json({
      success: true,
      timestamp,
      country: "JP",
      movieCount: moviesWithTrailer.length,
      movies: buildTestMoviePreview(moviesWithTrailer),
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
exports.testFetchMovieListCA = functions.runWith(movieRuntimeOptions).https.onRequest(async (req, res) => {
  try {
    const processedCount = 0;
    const startTime = Date.now();

    const allMovies = await fetchMovieListFromCineplex();
    const testMovies = limitTestItems(req, allMovies);

    console.log(`Cineplex Movies: ${allMovies.length}, test limit: ${testMovies.length}`);
    const moviesWithTrailer = await processBatch("en-CA", testMovies, processedCount, startTime);

    await writeMoviesToSheet("ca", moviesWithTrailer);

    const timestamp = new Date().toISOString();
    console.log(`Success: [${timestamp}] Country: CA, Movie Count: ${moviesWithTrailer.length}`);

    res.status(200).json({
      success: true,
      timestamp,
      country: "CA",
      movieCount: moviesWithTrailer.length,
      movies: buildTestMoviePreview(moviesWithTrailer),
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
exports.testFetchMovieListTW = functions.runWith(movieRuntimeOptions).https.onRequest(async (req, res) => {
  try {
    const allMovies = await fetchMovieListFromShowTime();
    const testMovies = limitTestItems(req, allMovies);
    const processedCount = 0;
    const startTime = Date.now();

    console.log(`ShowTime Movies: ${allMovies.length}, test limit: ${testMovies.length}`);

    const moviesWithDetails = await processBatch("zh-TW", testMovies, processedCount, startTime);
    await writeMoviesToSheet("tw", moviesWithDetails);

    const timestamp = new Date().toISOString();
    console.log(`Success: [${timestamp}] Country: TW, Movie Count: ${testMovies.length}`);

    res.status(200).json({
      success: true,
      timestamp,
      country: "TW",
      movieCount: testMovies.length,
      movies: buildTestMoviePreview(moviesWithDetails),
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
exports.testFetchMovieListFR = functions.runWith(movieRuntimeOptions).https.onRequest(async (req, res) => {
  try {
    const processedCount = 0;
    const startTime = Date.now();

    const allMovies = await fetchMovieListFromUga();
    const testMovies = limitTestItems(req, allMovies);

    console.log(`UGA Movies: ${allMovies.length}, test limit: ${testMovies.length}`);
    const moviesWithTrailer = await processBatch("fr-FR", testMovies, processedCount, startTime);

    await writeMoviesToSheet("fr", moviesWithTrailer);

    const timestamp = new Date().toISOString();
    console.log(`Success: [${timestamp}] Country: FR, Movie Count: ${moviesWithTrailer.length}`);

    res.status(200).json({
      success: true,
      timestamp,
      country: "FR",
      movieCount: moviesWithTrailer.length,
      movies: buildTestMoviePreview(moviesWithTrailer),
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
exports.testFetchMovieListDE = functions.runWith(movieRuntimeOptions).https.onRequest(async (req, res) => {
  try {
    const processedCount = 0;
    const startTime = Date.now();

    const allMovies = await fetchMovieListFromTMDBByDE();
    const testMovies = limitTestItems(req, allMovies);

    console.log(`Traumpalast Movies: ${allMovies.length}, test limit: ${testMovies.length}`);
    const moviesWithTrailer = await processBatch("de-DE", testMovies, processedCount, startTime, true);

    await writeMoviesToSheet("de", moviesWithTrailer);

    const timestamp = new Date().toISOString();
    console.log(`Success: [${timestamp}] Country: DE, Movie Count: ${moviesWithTrailer.length}`);

    res.status(200).json({
      success: true,
      timestamp,
      country: "DE",
      movieCount: moviesWithTrailer.length,
      movies: buildTestMoviePreview(moviesWithTrailer),
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
exports.testFetchMovieListUS = functions.runWith(movieRuntimeOptions).https.onRequest(async (req, res) => {
  try {
    const processedCount = 0;
    const startTime = Date.now();

    const allMovies = await fetchMovieListFromTMDBByUS();
    const testMovies = limitTestItems(req, allMovies);

    console.log(`TMDB US Movies: ${allMovies.length}, test limit: ${testMovies.length}`);
    const moviesWithTrailer = await processBatch("en-US", testMovies, processedCount, startTime, true);

    await writeMoviesToSheet("us", moviesWithTrailer);

    const timestamp = new Date().toISOString();
    console.log(`Success: [${timestamp}] Country: US, Movie Count: ${moviesWithTrailer.length}`);

    res.status(200).json({
      success: true,
      timestamp,
      country: "US",
      movieCount: moviesWithTrailer.length,
      movies: buildTestMoviePreview(moviesWithTrailer),
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
exports.testFetchMovieListTH = functions.runWith(movieRuntimeOptions).https.onRequest(async (req, res) => {
  try {
    const processedCount = 0;
    const startTime = Date.now();

    const allMovies = await fetchMovieListFromTMDBByTH();
    const testMovies = limitTestItems(req, allMovies);

    console.log(`SFCinema Movies: ${allMovies.length}, test limit: ${testMovies.length}`);
    const moviesWithTrailer = await processBatch("th-TH", testMovies, processedCount, startTime, true);

    await writeMoviesToSheet("th", moviesWithTrailer);

    const timestamp = new Date().toISOString();
    console.log(`Success: [${timestamp}] Country: TH, Movie Count: ${moviesWithTrailer.length}`);

    res.status(200).json({
      success: true,
      timestamp,
      country: "TH",
      movieCount: moviesWithTrailer.length,
      movies: buildTestMoviePreview(moviesWithTrailer),
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
exports.testFetchMovieListAU = functions.runWith(movieRuntimeOptions).https.onRequest(async (req, res) => {
  try {
    const processedCount = 0;
    const startTime = Date.now();

    const allMovies = await fetchMovieListFromTMDBByAU();
    const testMovies = limitTestItems(req, allMovies);

    console.log(`TMDB AU Movies: ${allMovies.length}, test limit: ${testMovies.length}`);
    const moviesWithTrailer = await processBatch("en-AU", testMovies, processedCount, startTime, true);

    await writeMoviesToSheet("au", moviesWithTrailer);

    const timestamp = new Date().toISOString();
    console.log(`Success: [${timestamp}] Country: AU, Movie Count: ${moviesWithTrailer.length}`);

    res.status(200).json({
      success: true,
      timestamp,
      country: "AU",
      movieCount: moviesWithTrailer.length,
      movies: buildTestMoviePreview(moviesWithTrailer),
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
exports.testFetchMovieListES = functions.runWith(movieRuntimeOptions).https.onRequest(async (req, res) => {
  try {
    const processedCount = 0;
    const startTime = Date.now();

    const allMovies = await fetchMovieListFromTMDBByES();
    const testMovies = limitTestItems(req, allMovies);

    console.log(`TMDB ES Movies: ${allMovies.length}, test limit: ${testMovies.length}`);
    const moviesWithTrailer = await processBatch("es-ES", testMovies, processedCount, startTime, true);

    await writeMoviesToSheet("es", moviesWithTrailer);

    const timestamp = new Date().toISOString();
    console.log(`Success: [${timestamp}] Country: ES, Movie Count: ${moviesWithTrailer.length}`);

    res.status(200).json({
      success: true,
      timestamp,
      country: "ES",
      movieCount: moviesWithTrailer.length,
      movies: buildTestMoviePreview(moviesWithTrailer),
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
exports.testFetchMovieListIN = functions.runWith(movieRuntimeOptions).https.onRequest(async (req, res) => {
  try {
    const processedCount = 0;
    const startTime = Date.now();

    const allMovies = await fetchMovieListFromTMDBByIN();
    const testMovies = limitTestItems(req, allMovies);

    console.log(`TMDB IN Movies: ${allMovies.length}, test limit: ${testMovies.length}`);
    const moviesWithTrailer = await processBatch("hi-IN", testMovies, processedCount, startTime, true);

    await writeMoviesToSheet("in", moviesWithTrailer);

    const timestamp = new Date().toISOString();
    console.log(`Success: [${timestamp}] Country: IN, Movie Count: ${moviesWithTrailer.length}`);

    res.status(200).json({
      success: true,
      timestamp,
      country: "IN",
      movieCount: moviesWithTrailer.length,
      movies: buildTestMoviePreview(moviesWithTrailer),
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
exports.testFetchMovieListCN = functions.runWith(movieRuntimeOptions).https.onRequest(async (req, res) => {
  try {
    const processedCount = 0;
    const startTime = Date.now();

    const runningMovies = await fetchRunningFromDouban();
    const upcomingMovies = await fetchUpcomingFromDouban();
    const allMovies = [...runningMovies, ...upcomingMovies];
    const testMovies = limitTestItems(req, allMovies);

    console.log(`TMDB CN Movies: ${allMovies.length}, test limit: ${testMovies.length}`);
    const moviesWithTrailer = await processBatch("zh-CN", testMovies, processedCount, startTime);

    await writeMoviesToSheet("cn", moviesWithTrailer);

    const timestamp = new Date().toISOString();
    console.log(`Success: [${timestamp}] Country: CN, Movie Count: ${moviesWithTrailer.length}`);

    res.status(200).json({
      success: true,
      timestamp,
      country: "CN",
      movieCount: moviesWithTrailer.length,
      movies: buildTestMoviePreview(moviesWithTrailer),
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
exports.testFetchMovieListSpecial = functions.runWith(movieRuntimeOptions).https.onRequest(async (req, res) => {
  try {
    const processedCount = 0;
    const startTime = Date.now();

    const specialMovies = selectNextSpecialPeriod(reuseExistingSpecialMovies(
        await fetchMovieInSpecialSection(),
        await readSpecialDataSheet(),
    ));
    const newMovies = specialMovies.filter((movie) => !movie.batch);
    const selectedNewMovies = limitTestItems(req, newMovies, true);
    const selectedKeys = new Set(selectedNewMovies.map((movie) =>
      `${movie.period}:${movie.tid}`));
    const testMovies = specialMovies.filter((movie) =>
      movie.batch || selectedKeys.has(`${movie.period}:${movie.tid}`));

    const moviesWithTrailer = await processBatchForSpecial("en-US", testMovies, processedCount, startTime);

    await saveMoviesAsJson("special", moviesWithTrailer);

    const timestamp = new Date().toISOString();
    console.log(`Success: [${timestamp}] Country: Special, Movie Count: ${moviesWithTrailer.length}`);

    res.status(200).json({
      success: true,
      timestamp,
      country: "Special",
      movieCount: moviesWithTrailer.length,
      movies: buildTestMoviePreview(moviesWithTrailer),
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
exports.testFetchQuoteListSpecial = functions.runWith(movieRuntimeOptions).https.onRequest(async (req, res) => {
  try {
    const specialQuotes = await fetchQuotesInSpecialSection();
    const testQuotes = limitTestItems(req, specialQuotes);

    await saveQuotesAsJson("special", testQuotes);

    const timestamp = new Date().toISOString();
    console.log(`Success: [${timestamp}] Country: Special, Quote Count: ${testQuotes.length}`);

    res.status(200).json({
      success: true,
      timestamp,
      country: "Special",
      quoteCount: testQuotes.length,
      quotes: testQuotes,
    });
  } catch (error) {
    console.error("Error fetching quote list:", error);
    res.status(500).json({success: false, error: error.message});
  }
});

/**
 * Test function for fetching and processing movie data from Mojo.
 * Can be triggered via an HTTP request.
 *
 * @param {Object} req - The request object.
 * @param {Object} res - The response object.
 * @returns {Promise<void>} Sends a JSON response when the function completes.
 */
exports.testFetchMovieListBoxOffice = functions.runWith(movieRuntimeOptions).https.onRequest(async (req, res) => {
  try {
    const processedCount = 0;
    const startTime = Date.now();

    const allMovies = await fetchMovieListFromMojo();
    const testMovies = limitTestItems(req, allMovies);

    console.log(`USA Box Office Movies: ${allMovies.length}, test limit: ${testMovies.length}`);
    const moviesWithTrailer = await processBatch("en-US", testMovies, processedCount, startTime);

    await writeMoviesToSheet("box_office", moviesWithTrailer);

    const timestamp = new Date().toISOString();
    console.log(`Success: [${timestamp}] Country: Box-Office-USA, Movie Count: ${moviesWithTrailer.length}`);

    res.status(200).json({
      success: true,
      timestamp,
      country: "Box-Office",
      movieCount: moviesWithTrailer.length,
      movies: buildTestMoviePreview(moviesWithTrailer),
    });
  } catch (error) {
    console.error("Error fetching movie list:", error);
    res.status(500).json({success: false, error: error.message});
  }
});

/**
 * Test function for fetching and processing Korean weekly KOBIS data.
 * @param {Object} req HTTP request containing an optional limit query.
 * @param {Object} res HTTP response.
 * @returns {Promise<void>} Sends the processed test result.
 */
exports.testFetchMovieListBoxOfficeKR = functions.runWith(kobisRuntimeOptions).https.onRequest(async (req, res) => {
  try {
    const processedCount = 0;
    const startTime = Date.now();
    const allMovies = await fetchMovieListFromKobis();
    const testMovies = limitTestItems(req, allMovies);

    console.log(`KOBIS Movies: ${allMovies.length}, test limit: ${testMovies.length}`);
    const moviesWithTrailer = await processBatch("ko-KR", testMovies, processedCount, startTime);
    await writeMoviesToSheet("box_office_kr", moviesWithTrailer);

    const timestamp = new Date().toISOString();
    console.log(`Success: [${timestamp}] Country: Box-Office-KR, Movie Count: ${moviesWithTrailer.length}`);
    res.status(200).json({
      success: true,
      timestamp,
      country: "Box-Office-KR",
      movieCount: moviesWithTrailer.length,
      movies: buildTestMoviePreview(moviesWithTrailer),
    });
  } catch (error) {
    console.error("Error fetching Korean box office:", error);
    res.status(500).json({success: false, error: error.message});
  }
});

// Manual Storage tests. Run the matching testFetch first, then invoke these.
exports.testStoreMovieListKR = createTestStore("kr");
exports.testStoreMovieListJP = createTestStore("jp");
exports.testStoreMovieListCA = createTestStore("ca");
exports.testStoreMovieListTW = createTestStore("tw");
exports.testStoreMovieListFR = createTestStore("fr");
exports.testStoreMovieListDE = createTestStore("de");
exports.testStoreMovieListUS = createTestStore("us");
exports.testStoreMovieListTH = createTestStore("th");
exports.testStoreMovieListAU = createTestStore("au");
exports.testStoreMovieListES = createTestStore("es");
exports.testStoreMovieListIN = createTestStore("in");
exports.testStoreMovieListCN = createTestStore("cn");
exports.testStoreMovieListBoxOffice = createTestStore("box_office");
exports.testStoreMovieListBoxOfficeKR = createTestStore("box_office_kr");

/**
 * Republishes one finalized worksheet without crawling or calling TMDB/YouTube.
 * @param {Object} req HTTP request with a country query/body value.
 * @param {Object} res HTTP response.
 * @returns {Promise<void>} Sends the Storage publishing result.
 */
exports.syncMovieSheetToStorage = functions.runWith({timeoutSeconds: 300}).https.onRequest((req, res) => {
  corsHandler(req, res, async () => {
    if (req.method !== "POST") {
      res.status(405).json({success: false, error: "Use POST."});
      return;
    }
    const country = String(req.body && req.body.country || req.query.country || "").trim().toLowerCase();
    if (!SHEET_SYNC_COUNTRIES.has(country)) {
      res.status(400).json({success: false, error: "Unsupported country or category."});
      return;
    }
    try {
      const published = await publishSheetMovies(country);
      res.status(200).json({
        success: true,
        country,
        timestamp: published.timestamp,
        movieCount: published.movies.length,
      });
    } catch (error) {
      console.error(`Error syncing ${country} Sheet to Storage:`, error);
      res.status(500).json({success: false, error: error.message});
    }
  });
});

/**
 * Reads a movie list JSON file from Firebase Storage based on the provided country code.
 * Can be triggered via an HTTP request with a country query parameter.
 *
 * @param {Object} req - The request object.
 * @param {Object} res - The response object.
 * @returns {Promise<void>} Sends a JSON response with the movie list when the function completes.
 */
exports.readMovieListByCountry = functions.https.onRequest((req, res) => {
  corsHandler(req, res, async () => {
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
});

/**
   * Saves new promotion url as a JSON file in Firebase Storage.
   *
   * @param {string} newUrl - new trailer url
   * @return {Promise<void>} Saves the quote list in Firebase Storage.
   */
exports.updatePromotionUrl = functions.https.onRequest((req, res) => {
  corsHandler(req, res, async () => {
    const {newUrl} = req.body;

    if (!newUrl) {
      return res.status(400).json({success: false, message: "Missing required parameters."});
    }

    try {
      const result = await updatePromotionUrl(newUrl);
      res.status(200).json(result);
    } catch (error) {
      console.error("Error in updatePromotionUrl function:", error);
      res.status(500).json({success: false, error: error.message});
    }
  });
});

/**
 * Reads a promotion url JSON file from Firebase Storage based on the provided country code.
 *
 * @param {Object} req - The request object.
 * @param {Object} res - The response object.
 * @returns {Promise<void>} Sends a JSON response with the promotion ul when the function completes.
 */
exports.readPromotionUrl = functions.https.onRequest((req, res) => {
  corsHandler(req, res, async () => {
    try {
      const bucket = admin.storage().bucket();
      const fileName = `promotion_url.json`;
      const file = bucket.file(fileName);

      const exists = await file.exists();
      if (!exists[0]) {
        return res.status(404).json({success: false, message: "File not found."});
      }

      const fileContents = await file.download();
      const url = JSON.parse(fileContents.toString());

      res.status(200).json(url);
    } catch (error) {
      console.error("Error reading url:", error);
      res.status(500).json({success: false, error: error.message});
    }
  });
});

exports.updateHotFixMode = functions.https.onRequest((req, res) => {
  corsHandler(req, res, async () => {
    const {hotFixMode} = req.body;

    if (typeof hotFixMode !== "boolean") {
      return res.status(400).json({success: false, message: "Missing or invalid hotFixMode (must be boolean)."});
    }

    try {
      const bucket = admin.storage().bucket();
      const file = bucket.file("hotFixMode.json");

      const exists = await file.exists();
      if (!exists[0]) {
        return res.status(404).json({success: false, message: "File not found."});
      }

      const contentBuffer = await file.download();
      const jsonData = JSON.parse(contentBuffer.toString());

      // Update hotFixMode only
      jsonData.hotFixMode = hotFixMode;

      await file.save(JSON.stringify(jsonData), {
        contentType: "application/json",
      });

      res.status(200).json({success: true, message: "hotFixMode updated.", hotFixMode});
    } catch (error) {
      console.error("Error updating hotFixMode:", error);
      res.status(500).json({success: false, error: error.message});
    }
  });
});

exports.readHotFixMode = functions.https.onRequest((req, res) => {
  corsHandler(req, res, async () => {
    try {
      const bucket = admin.storage().bucket();
      const file = bucket.file("hotFixMode.json");

      const exists = await file.exists();
      if (!exists[0]) {
        return res.status(404).json({success: false, message: "File not found."});
      }

      const contentBuffer = await file.download();
      const jsonData = JSON.parse(contentBuffer.toString());

      const hotFixMode = jsonData.hotFixMode;

      res.status(200).json({success: true, hotFixMode});
    } catch (error) {
      console.error("Error reading hotFixMode:", error);
      res.status(500).json({success: false, error: error.message});
    }
  });
});
