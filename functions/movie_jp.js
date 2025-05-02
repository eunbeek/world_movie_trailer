/* eslint-disable max-len */
const axios = require("axios");
const cheerio = require("cheerio");

const currentDate = new Date();

// 1개월 후
const futureDateStart = new Date(currentDate.getTime());
futureDateStart.setMonth(currentDate.getMonth() + 1);

// 3개월 후
const futureDateEnd = new Date(currentDate.getTime());
futureDateEnd.setMonth(currentDate.getMonth() + 3);

// 연도 및 월 계산
const futureYearStart = futureDateStart.getFullYear();
const futureMonthStart = futureDateStart.getMonth() + 1;

const futureYearEnd = futureDateEnd.getFullYear();
const futureMonthEnd = futureDateEnd.getMonth() + 1;

// URL 생성
const eigaAllRelease = `https://eiga.com/release/q/?year=${futureYearStart}&month=${futureMonthStart}&year_to=${futureYearEnd}&month_to=${futureMonthEnd}&sort=old`;

const eigaRunning = "https://eiga.com/now/";
const eigaMore = "https://eiga.com/now/all/release/2/";

/**
 * Fetches all running movies from EIGA (both current and more).
 * @param {Array} [moviesJP] - List of movies to avoid duplicates.
 * @return {Promise<Array>} - A promise that resolves to a list of running movies.
 */
async function fetchRunningFromEIGA() {
  const urls = [eigaRunning, eigaMore, eigaAllRelease];
  const movies = [];

  for (const url of urls) {
    try {
      const response = await axios.get(url);

      if (response.status !== 200) {
        throw new Error("Failed to load EIGA movies");
      }

      const $ = cheerio.load(response.data);
      const movieBoxes = $("section div.list-block");

      const promises = movieBoxes.map(async (i, movieBox) => {
        const aTag = $(movieBox).find("div.img-box a");
        if (aTag) {
          const title = $(aTag).find("img").attr("alt").trim();
          const posterUrl = $(aTag).find("img").attr("src");
          const releaseDate = $(movieBox).find("small.time").text().trim().replace(/劇場公開日|公開/g, "");

          if (posterUrl && posterUrl.startsWith("https://eiga.k-img.com/images/movie/noimg")) {
            return; // Skip this movie and move to the next one
          }

          // Extract the current year
          const currentDate = new Date();
          const year = currentDate.getFullYear();

          // Extract month and day from the release date
          const match = releaseDate.match(/(\d{1,2})月(\d{1,2})日/);
          if (!match) {
            console.warn(`🚨 Skipping movie due to invalid release date format: ${title} | releaseDate: ${releaseDate}`);
            return; // Skip movies with invalid release dates
          }

          const [, month, day] = match;

          // Create a tentative release date using the current year
          const tentativeReleaseDate = new Date(year, month - 1, day);

          // Check if the tentative release date is more than 6 months in the future
          const sixMonthsFromNow = new Date();
          sixMonthsFromNow.setMonth(currentDate.getMonth() + 6);

          if (tentativeReleaseDate > sixMonthsFromNow) {
            // If the date is more than 6 months in the future, assume it's for the next year
            tentativeReleaseDate.setFullYear(year + 1);
          }

          // Format the date as YYYY-MM-DD
          const formattedDate = `${tentativeReleaseDate.getFullYear()}-${(tentativeReleaseDate.getMonth() + 1).toString().padStart(2, "0")}-${tentativeReleaseDate.getDate().toString().padStart(2, "0")}`;

          const spec = $(movieBox).find("p.txt").text().trim();

          const director = $(movieBox).find("ul.cast-staff li:first-child span").text().trim();
          const cast = $(movieBox)
              .find("ul.cast-staff li:nth-child(2) span")
              .map((i, el) => $(el).text().trim())
              .get()
              .slice(0, 4);

          if (!movies.some((movie) => movie.localTitle === title)) {
            movies.push({
              localTitle: title,
              posterUrl: posterUrl,
              source: "eiga",
              spec: spec,
              releaseDate: formattedDate,
              credits: {
                crew: director ? [{name: director, job: "Director"}] : [],
                cast: cast.map((name) => ({name: name})), // Assuming no character info available
              },
              batch: false,
            });
          }
        }
      }).get();

      await Promise.all(promises);
    } catch (error) {
      console.error("Error fetching from EIGA:", error);
    }
  }

  return movies;
}

module.exports = {
  fetchRunningFromEIGA,
};
