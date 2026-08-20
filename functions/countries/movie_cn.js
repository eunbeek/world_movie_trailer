/* eslint-disable max-len */
const axios = require("axios");
const cheerio = require("cheerio");

const doubanRunning = "https://movie.douban.com/cinema/nowplaying/beijing/";
const doubanUpcoming = "https://movie.douban.com/cinema/later/beijing/";

const doubanMovieHeader = {
  "accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
  "accept-encoding": "gzip, deflate, br, zstd",
  "accept-language": "en-US,en;q=0.9,ko-KR;q=0.8,ko;q=0.7",
  "cache-control": "max-age=0",
  "cookie": "bid=3UcJ7ME4jsg; _pk_ref.100001.4cf6=%5B%22%22%2C%22%22%2C1742090923%2C%22https%3A%2F%2Fwww.google.com%2F%22%5D; _pk_id.100001.4cf6=b2e968850707c284.1742090923.; _pk_ses.100001.4cf6=1; __utma=30149280.1463305897.1742090923.1742090923.1742090923.1; __utmb=30149280.0.10.1742090923; __utmc=30149280; __utmz=30149280.1742090923.1.1.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not%20provided); __utma=223695111.1036982146.1742090923.1742090923.1742090923.1; __utmb=223695111.0.10.1742090923; __utmc=223695111; __utmz=223695111.1742090923.1.1.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not%20provided); ap_v=0,6.0; __yadk_uid=k8zRs3eQaFJkgXjcQoWUyBZ6FoKzDFkW",
  "priority": "u=0, i",
  "referer": "https://www.google.com/",
  "sec-ch-ua": "\"Chromium\";v=\"134\", \"Not:A-Brand\";v=\"24\", \"Google Chrome\";v=\"134\"",
  "sec-ch-ua-mobile": "?0",
  "sec-ch-ua-platform": "\"macOS\"",
  "sec-fetch-dest": "document",
  "sec-fetch-mode": "navigate",
  "sec-fetch-site": "cross-site",
  "sec-fetch-user": "?1",
  "upgrade-insecure-requests": "1",
  "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_0_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36",
};

/**
 * Fetches currently playing movies from Douban (Beijing).
 * @return {Promise<Array>} - A promise that resolves to a list of movies.
 */
async function fetchRunningFromDouban() {
  try {
    const response = await axios.get(doubanRunning, {
      headers: doubanMovieHeader,
    });

    if (response.status !== 200) {
      throw new Error("Failed to fetch Douban Now Playing movies.");
    }

    // HTML 파싱
    const $ = cheerio.load(response.data);
    const movies = [];

    $("#nowplaying .list-item").each((_, element) => {
      const title = $(element).attr("data-title");
      const posterUrl = $(element).find(".poster img").attr("src");
      if (title && posterUrl) {
        movies.push({
          localTitle: title,
          posterUrl: posterUrl,
          source: "douban",
          batch: false,
        });
      }
    });
    return movies;
  } catch (error) {
    console.error("Error fetching movies:", error);
  }
}

/**
 * Fetches upcoming movies from Douban (Beijing).
 * @return {Promise<Array>} - A promise that resolves to a list of movies.
 */
async function fetchUpcomingFromDouban() {
  try {
    const response = await axios.get(doubanUpcoming, {
      headers: doubanMovieHeader,
    },
    );

    if (response.status !== 200) {
      throw new Error("Failed to fetch Douban upcoming movies.");
    }

    // HTML 파싱
    const $ = cheerio.load(response.data);
    const movies = [];

    $("#showing-soon .item").each((_, element) => {
      const title = $(element).find(".intro h3 a").text().trim();
      if (title) {
        movies.push({
          localTitle: title,
          source: "douban",
          batch: false,
        });
      }
    });
    return movies;
  } catch (error) {
    console.error("Error fetching upcoming movies from Douban:", error);
    return [];
  }
}

module.exports = {
  fetchRunningFromDouban,
  fetchUpcomingFromDouban,
};
