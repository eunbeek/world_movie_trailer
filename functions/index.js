/* eslint-disable max-len */
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const {fetchMovieListFromCgv, fetchMovieListFromLotte} = require("./movie_kr");
const {fetchRunningFromEIGA, fetchUpcomingFromEIGA} = require("./movie_jp");
const {fetchMovieInSpecialSection} = require("./movie_special");
const {searchMovieInfoByTitle, searchSpecialMovieInfoByTid} = require("./tmdb");

admin.initializeApp();

/**
 * Fetches movies from CGV and Lotte, processes trailers, and saves the result.
 * Scheduled to run every Monday at 09:00 AM KST.
 *
 * @returns {Promise<null>} Returns null when the function completes.
 */
exports.fetchMovieListKR = functions.pubsub
    .schedule("0 9 * * 1")
    .timeZone("America/Toronto")
    .onRun(async (context) => {
      const processedCount = 0;
      const startTime = Date.now();

      // fetch movie name, country, source from KR theater
      const lotteMovies = await fetchMovieListFromLotte();
      const cgvMovies = await fetchMovieListFromCgv(lotteMovies);
      const allMovies = [...lotteMovies, ...cgvMovies];

      // fetch movie trailer, spec, poster, release date from TMDB
      const moviesWitgDetails = await processBatch("ko-KR", allMovies, processedCount, startTime);

      // save movies to storage
      await saveMoviesAsJson("kr", moviesWitgDetails);

      const timestamp = new Date().toISOString();
      console.log(`Success: [${timestamp}] Country: KR, Movie Count: ${moviesWitgDetails.length}`);

      return null;
    });

/**
 * Fetches movies from EIGA, processes trailers, and saves the result.
 * Scheduled to run every Tuesday at 09:00 AM JST.
 *
 * @returns {Promise<null>} Returns null when the function completes.
 */
exports.fetchMovieListJP = functions.pubsub
    .schedule("0 9 * * 2")
    .timeZone("Asia/Tokyo")
    .onRun(async (context) => {
      const processedCount = 0;
      const startTime = Date.now();

      // fetch movie name, country, source from KR theater
      const runningMovies = await fetchRunningFromEIGA(false);
      const upcomingMovies = await fetchUpcomingFromEIGA(false);
      const allMovies = [...runningMovies, ...upcomingMovies];

      // fetch movie trailer, spec, poster, release date from TMDB
      const moviesWithTrailer = await processBatch("ja-JP", allMovies, processedCount, startTime);

      // save movies to storage
      await saveMoviesAsJson("jp", moviesWithTrailer);

      const timestamp = new Date().toISOString();
      console.log(`Success: [${timestamp}] Country: JP, Movie Count: ${moviesWithTrailer.length}`);

      return null;
    });

/**
 * Processes a batch of movies to fetch trailers and updates the list.
 *
 * @param {string} country - The country code for the movies.
 * @param {Array} moviesData - The list of movies to process.
 * @param {number} processedCount - The count of processed movies.
 * @param {number} startTime - The start time of the batch process.
 * @param {boolean} isSpecial - The special section movie or not.
 * @return {Promise<Array>} The updated list of movies.
 */
async function processBatch(country, moviesData, processedCount, startTime, isSpecial = false) {
  const unprocessedMovies = moviesData.filter((movie) => !movie.spec);
  console.log(`unprocessMovies: ${unprocessedMovies.length}`);
  if (unprocessedMovies.length === 0) {
    console.log("All movies processed. No further action needed.");
    return moviesData;
  }

  const moviesToProcess = unprocessedMovies.slice(0, 10);

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
        movie.trailerUrl = fetchedMovie.trailerLink || "",
        movie.spec = fetchedMovie.overview || "ERR404",
        movie.releaseDate = fetchedMovie.release_date || "";
        movie.runtime = fetchedMovie.runtime || "";
        movie.credits = fetchedMovie.credits || {};
      } else {
        movie.spec = "ERR404";
      }
    } catch (error) {
      console.error(`Error processing movie ${movie.originalTitle}:`, error);
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
 */
async function saveMoviesAsJson(country, movies) {
  const bucket = admin.storage().bucket();
  const mainFileName = `movies_${country}.json`;
  const moviesWithTrailer = movies.filter((movie) => {
    return movie.trailerUrl !== "ERR404";
  });
  const jsonData = JSON.stringify(moviesWithTrailer, null, 2);

  try {
    // Overwrite the main file
    await bucket.file(mainFileName).save(jsonData, {
      metadata: {
        contentType: "application/json",
      },
    });
  } catch (error) {
    console.error("Error saving file to Firebase Storage:", error);
  }
}

exports.fetchSpeicalSectionByDirector = functions.runWith({timeoutSeconds: 540}).https.onRequest(async (req, res) => {
  try {
    const processedCount = 0;
    const startTime = Date.now();

    const specialMovies = await fetchMovieInSpecialSection();

    console.log(`specialMovies : ${specialMovies.length}`);

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

exports.testFetchMovieListJP = functions.runWith({timeoutSeconds: 540}).https.onRequest(async (req, res) => {
  try {
    const processedCount = 0;
    const startTime = Date.now();

    // fetch movie name, country, source from KR theater
    const runningMovies = await fetchRunningFromEIGA(false);
    const upcomingMovies = await fetchUpcomingFromEIGA(false);
    const allMovies = [...runningMovies, ...upcomingMovies];

    // fetch movie trailer, spec, poster, release date from TMDB
    const moviesWithTrailer = await processBatch("ja-JP", allMovies, processedCount, startTime);

    // save movies to storage
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