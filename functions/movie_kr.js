/* eslint-disable max-len */
const axios = require("axios");
const cheerio = require("cheerio");

const cgvUrlRunning = "http://www.cgv.co.kr/movies/?lt=1&ft=1";
const cgvUrlUpcoming = "http://www.cgv.co.kr/movies/pre-movies.aspx";
const cgvMoreMoviesUrl = "https://www.cgv.co.kr/common/ajax/movies.aspx/GetMovieMoreList?listType=1&orderType=1&filterType=1";

const cgvMoreMovieHeader = {
  "Accept": "application/json, text/javascript, */*; q=0.01",
  "Accept-Encoding": "gzip, deflate",
  "Accept-Language": "en-US,en;q=0.9,ko-KR;q=0.8,ko;q=0.7",
  "Connection": "keep-alive",
  "Content-Type": "application/json; charset=utf-8",
  "Host": "www.cgv.co.kr",
  "Referer": "http://www.cgv.co.kr/movies/",
  "X-Requested-With": "XMLHttpRequest",
};

const lotteDetail = "https://www.lottecinema.co.kr/LCWS/Movie/MovieData.aspx";
const lotteRunningHeader = {
  "MethodName": "GetMoviesToBe",
  "channelType": "HO",
  "osType": "Chrome",
  "osVersion": "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_0_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36",
  "multiLanguageID": "US",
  "division": 1,
  "moviePlayYN": "Y",
  "orderType": "1",
  "blockSize": 100,
  "pageNo": 1,
  "memberOnNo": "",
};
const lotteUpcomingHeader = {
  "MethodName": "GetMoviesToBe",
  "channelType": "HO",
  "osType": "Chrome",
  "osVersion": "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_0_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36",
  "multiLanguageID": "US",
  "division": 1,
  "moviePlayYN": "N",
  "orderType": "1",
  "blockSize": 100,
  "pageNo": 1,
  "memberOnNo": "",
};

/**
 * Fetches movie data from CGV, excluding movies already in the Lotte list.
 * @param {Array} lotteMovies
 * - The list of movies fetched from Lotte.
 * @return {Promise<Array>}
 * A promise that resolves to a list of movies from CGV.
 */
async function fetchMovieListFromCgv(lotteMovies) {
  const movies = [];
  const cgvUrls = [cgvUrlRunning, cgvUrlUpcoming];

  for (const url of cgvUrls) {
    try {
      const response = await axios.get(url);
      const $ = cheerio.load(response.data);
      const movieBoxes = $("div.sect-movie-chart ol li");
      const startPointByStatus = url === cgvUrlRunning ? 0 : 3;

      const promises = movieBoxes.map(async (i, elem) => {
        if (i < startPointByStatus) return;

        const titleElement = $(elem).find(".box-contents .title");
        const localTitle = titleElement.text().trim();

        const processedTitle = localTitle.startsWith("[") ?
          localTitle.replace(/^\[.*?\]/, "").trim() :
          localTitle;

        if (lotteMovies.some((movie) => movie.localTitle === processedTitle)) {
          return;
        }
        const posterUrl = $(elem).find(".thumb-image img").attr("src");
        const movie = {
          localTitle: processedTitle,
          posterUrl: posterUrl,
          country: "kr",
          source: "cgv",
          batch: false,
        };

        movies.push(movie);
      }).get(); // Convert cheerio collection to array

      await Promise.all(promises);

      if (url === cgvUrlRunning) {
        const additionalMoviesResponse =
              await axios.get(cgvMoreMoviesUrl, {headers: cgvMoreMovieHeader});
        if (additionalMoviesResponse.status !== 200) {
          throw new Error(`Failed to fetch additional movies. Status: ${additionalMoviesResponse.status}`);
        }
        const jsonResponse = additionalMoviesResponse.data;
        // Assuming 'd' contains the nested JSON string
        const additionalMoviesData = JSON.parse(jsonResponse["d"]);

        await _processAdditionalMovies(additionalMoviesData["List"], movies, lotteMovies);
      }
    } catch (error) {
      console.error("Error fetching from CGV:", error);
    }
  }

  return movies;
}

/**
 * Processes additional movies fetched from CGV and adds them to the list.
 * @param {Array} movieList
 * - The list of additional movies from CGV.
 * @param {Array} movies
 *  - The list of movies to add to.
 * @param {Array} lotteMovies
 * - The list of movies fetched from Lotte to avoid duplicates.
 */
async function _processAdditionalMovies(movieList, movies, lotteMovies) {
  if (!movieList) return;

  const promises = movieList.map(async (movieJson) => {
    try {
      const localTitle = movieJson.Title || "Unknown";
      const posterUrl = movieJson.PosterImage.LargeImage;
      const processedTitle = localTitle.startsWith("[") ?
        localTitle.replace(/^\[.*?\]/, "").trim() :
        localTitle;

      if (lotteMovies.some((movie) => movie.localTitle === processedTitle)) {
        return;
      }

      const movie = {
        localTitle: processedTitle,
        posterUrl: posterUrl,
        source: "cgv",
        batch: false,
      };

      movies.push(movie);
    } catch (error) {
      console.error("Error processing additional movie:", error);
    }
  });

  await Promise.all(promises);
}

/**
 * Fetches movie data from Lotte Cinema.
 * @return {Promise<Array>}
 * A promise that resolves to a list of movies from Lotte Cinema.
 */
async function fetchMovieListFromLotte() {
  const requestDataList = [lotteRunningHeader, lotteUpcomingHeader];
  const movies = [];

  for (const requestData of requestDataList) {
    try {
      const formData = new URLSearchParams();
      formData.append("ParamList", JSON.stringify(requestData));

      const response = await axios.post(lotteDetail, formData.toString(), {
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
      });

      const responseData = response.data;

      if (responseData.IsOK === "false") {
        console.error("Error: ", responseData.ResultMessage);
        continue;
      }

      const moviesList = responseData.Movies.Items;

      const promises = moviesList.map(async (movieJson) => {
        if (movieJson.RepresentationMovieCode === "AD") return;

        const processedTitle = movieJson.MovieNameKR.startsWith("[") ?
          movieJson.MovieNameKR.replace(/^\[.*?\]/, "").trim() :
          movieJson.MovieNameKR.trim();

        movies.push({
          localTitle: processedTitle,
          posterUrl: movieJson.PosterURL,
          source: "lotte",
          batch: false,
        });
      });

      await Promise.all(promises);
    } catch (error) {
      console.error("Error fetching from Lotte:", error);
    }
  }

  return movies;
}

module.exports = {
  fetchMovieListFromCgv,
  fetchMovieListFromLotte,
};
