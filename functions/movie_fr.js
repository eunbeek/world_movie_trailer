/* eslint-disable max-len */
const axios = require("axios");
const cheerio = require("cheerio");

const ugcRunningUrl = "https://www.ugc.fr/filmsAjaxAction!getFilmsAndFilters.action?filter=stillOnDisplay&page=30010&cinemaId=&reset=false&";
const ugcUpcomingUrl = "https://www.ugc.fr/filmsAjaxAction!getFilmsAndFilters.action?filter=onPreview&page=30010&cinemaId=&reset=false&";
const ugcHeaders = {
  "authority": "www.ugc.fr",
  "method": "GET",
  "scheme": "https",
  "accept": "text/html, */*; q=0.01",
  "accept-encoding": "gzip, deflate, br, zstd",
  "accept-language": "en-US,en;q=0.9,ko-KR;q=0.8,ko;q=0.7",
  "cookie": "hagreedId=01212c26-6811-43d3-934d-86b351dd5238; _pk_ref.2.931e=%5B%22%22%2C%22%22%2C1724820533%2C%22https%3A%2F%2Fwww.google.com%2F%22%5D; _pk_id.2.931e=99cf2d8b2fe83983.1724820533.; _pk_ses.2.931e=1; hagreedCookies=[%22doubleclick%22%2C%22mobkoi_ltd%22%2C%22prehome_ugc%22%2C%22madinad_pc%22%2C%22ab_tasty%22%2C%22batch%22%2C%22google%22%2C%22matomo_ecommerce%22%2C%22new_relic%22]; abtastyOK=true; _ga=GA1.1.688492143.1724820539; advertisingCampaign1498Cookie=1; currentCinemaId=; JSESSIONID=4E5768F94A5894C757AB7B49EBE98F9F; _ga_29RY7XW3SW=GS1.1.1724820538.1.1.1724825353.60.0.0",
  "priority": "u=1, i",
  "referer": "https://www.ugc.fr/films.html?filter=onPreview",
  "sec-ch-ua": "\"Not)A;Brand\";v=\"99\", \"Google Chrome\";v=\"127\", \"Chromium\";v=\"127\"",
  "sec-ch-ua-mobile": "?0",
  "sec-ch-ua-platform": "\"macOS\"",
  "sec-fetch-dest": "empty",
  "sec-fetch-mode": "cors",
  "sec-fetch-site": "same-origin",
  "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36",
  "x-requested-with": "XMLHttpRequest",
};

/**
 * Fetches movie data from UGC
 * @return {Promise<Array>}
 * A promise that resolves to a list of movies from UGC.
 */
async function fetchMovieListFromUga() {
  const urls = [ugcRunningUrl, ugcUpcomingUrl];
  const movies = [];

  for (const url of urls) {
    try {
      const response = await axios.get(url, {headers: ugcHeaders});
      const $ = cheerio.load(response.data);
      const movieBoxes = $("div.visu-wrapper");

      movieBoxes.each((i, movieBox) => {
        const aTag = $(movieBox).find("a");
        const movie = {
          localTitle: aTag.attr("title"),
          posterUrl: aTag.find("img").attr("data-src"),
          source: "ugc",
          batch: false,
        };
        movies.push(movie);
      });
    } catch (err) {
      console.error("Error fetching from UGC:", err);
    }
  }

  return movies;
}

module.exports = {
  fetchMovieListFromUga,
};
