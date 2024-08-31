/* eslint-disable max-len */
const axios = require("axios");
const cheerio = require("cheerio");

const traumpalastRunningUrl ="https://leonberg.traumpalast.de/index.php/PID/5796.html";
const traumpalastUpcomingUrl = "https://leonberg.traumpalast.de/index.php/PID/5842.html";
const traumpalastUpcoming2Url = "https://leonberg.traumpalast.de/index.php/PID/5842/seite/2.html";
const traumpalastUpcoming3Url = "https://leonberg.traumpalast.de/index.php/PID/5842/seite/3.html";

/**
 * Fetches movie data from Traumpalast
 * @return {Promise<Array>}
 * A promise that resolves to a list of movies from Traumpalast.
 */
async function fetchMovieListFromTraumpalast() {
  const urls = [traumpalastRunningUrl, traumpalastUpcomingUrl, traumpalastUpcoming2Url, traumpalastUpcoming3Url];
  const movies = [];

  for (const url of urls) {
    try {
      const response = await axios.get(url);
      const $ = cheerio.load(response.data);
      const movieBoxes = $("div.contentbox.movie");

      movieBoxes.each((i, movieBox) => {
        const aTag = $(movieBox).find("a.no-decoration");
        const imgTag = $(aTag).find("img");
        const titleTag = $(movieBox).find("h3.headline-blue a");
        const descriptionTag = $(movieBox).find("p[itemprop='description']");
        const releaseDateTag = $(movieBox).find("time[itemprop='datePublished']");
        const runtimeTag = $(movieBox).find("span[itemprop='duration']");

        const movie = {
          localTitle: titleTag.text().trim(),
          posterUrl: "https://leonberg.traumpalast.de" + imgTag.attr("data-srcset").split(" ")[0],
          source: "traumpalast",
          spec: descriptionTag.text().trim(),
          releaseDate: releaseDateTag.attr("datetime"),
          runtime: runtimeTag.text().replace(" Minuten", "").trim(),
          batch: false,
        };

        movies.push(movie);
      });
    } catch (err) {
      console.error("Error fetching from Traumpalast:", err);
    }
  }

  return movies;
}

module.exports = {
  fetchMovieListFromTraumpalast,
};
