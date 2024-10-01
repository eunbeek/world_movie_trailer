/* eslint-disable max-len */
const axios = require("axios");
const cheerio = require("cheerio");

const currentDate = new Date();
const currentYear = currentDate.getFullYear();
const currentMonth = currentDate.getMonth() + 2;

// 2개월 후의 날짜를 계산
const futureDate = new Date(currentDate.setMonth(currentDate.getMonth() + 2));
const futureYear = futureDate.getFullYear();
const futureMonth = futureDate.getMonth() + 1; // 월은 0부터 시작하므로 1을 더해줌

const eigaAllRelease = `https://eiga.com/release/q/?year=${currentYear}&month=${currentMonth}&year_to=${futureYear}&month_to=${futureMonth}&sort=old`;
const eigaRunning = "https://eiga.com/now/";
const eigaUpcoming = "https://eiga.com/movie/video/upcoming";
const eigaMore = "https://eiga.com/now/all/release/2/";
const eigaMoreUpcoming = "https://eiga.com/movie/video/coming/";

/**
 * Fetches all running movies from EIGA (both current and more).
 * @param {Array} [moviesJP] - List of movies to avoid duplicates.
 * @return {Promise<Array>} - A promise that resolves to a list of running movies.
 */
async function fetchRunningFromEIGA(moviesJP = []) {
  const urls = [eigaRunning, eigaMore, eigaAllRelease];
  const movies = [];

  for (const url of urls) {
    console.log(url);
    try {
      const response = await axios.get(url);

      if (response.status !== 200) {
        throw new Error("Failed to load EIGA movies");
      }

      const $ = cheerio.load(response.data);
      const movieBoxes = $("section div.list-block");

      const promises = movieBoxes.slice(0, 50).map(async (i, movieBox) => {
        const aTag = $(movieBox).find("div.img-box a");
        if (aTag) {
          const title = $(aTag).find("img").attr("alt").trim();
          if (moviesJP.length > 0 && moviesJP.some((movieJP) => movieJP.localTitle === title)) return;

          const posterUrl = $(aTag).find("img").attr("src");
          const releaseDate = $(movieBox).find("small.time").text().trim().replace(/劇場公開日|公開/g, "");

          // Extract the current year
          const currentDate = new Date();
          const year = currentDate.getFullYear();

          // Extract month and day from the release date
          const [_, month, day] = releaseDate.match(/(\d{1,2})月(\d{1,2})日/) || [];
          console.log(_);
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

/**
 * Fetches all upcoming movies from EIGA (both current and more upcoming).
 * @param {Array} [moviesJP] - List of movies to avoid duplicates.
 * @return {Promise<Array>} - A promise that resolves to a list of upcoming movies.
 */
async function fetchUpcomingFromEIGA(moviesJP = []) {
  const urls = [eigaUpcoming, eigaMoreUpcoming];
  const movies = [];

  for (const url of urls) {
    try {
      const response = await axios.get(url);

      if (response.status !== 200) {
        throw new Error("Failed to load EIGA movies");
      }

      const $ = cheerio.load(response.data);
      const movieBoxes = $("li.col-s-4");

      const promises = movieBoxes.map(async (i, movieBox) => {
        const aTag = $(movieBox).find("a");
        if (aTag) {
          const title = $(movieBox).find("div.img-thumb img").attr("alt").trim();
          if (moviesJP.length > 0 && moviesJP.some((movieJP) => movieJP.localTitle === title)) return;

          const posterUrl = $(movieBox).find("div.img-thumb img").attr("src");
          const releaseDate = $(movieBox).find("p.published").text().trim().replace("劇場公開日：", "");

          // Convert Japanese date format (e.g., 2024年8月31日) to YYYY-MM-DD
          const formattedDate = releaseDate.replace(/(\d{4})年(\d{1,2})月(\d{1,2})日/, (match, year, month, day) => {
            // Ensure month and day are two digits
            month = month.padStart(2, "0");
            day = day.padStart(2, "0");
            return `${year}-${month}-${day}`;
          });

          movies.push({
            localTitle: title,
            posterUrl: posterUrl,
            source: "eiga",
            releaseDate: formattedDate,
            credits: {
              crew: [],
              cast: [],
            },
            batch: false,
          });
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
  fetchUpcomingFromEIGA,
};
