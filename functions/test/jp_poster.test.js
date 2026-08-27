/* eslint-disable max-len */
const assert = require("node:assert/strict");
const {test} = require("node:test");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");

/**
 * Loads a module with isolated network/service dependencies.
 * @param {string} relativePath Module path from functions.
 * @param {Object} mocks Dependency overrides.
 * @return {Object} Module exports.
 */
function loadModule(relativePath, mocks) {
  const module = {exports: {}};
  vm.runInNewContext(fs.readFileSync(path.join(__dirname, "..", relativePath), "utf8"), {
    module,
    require: (name) => Object.prototype.hasOwnProperty.call(mocks, name) ? mocks[name] : require(name),
    console: {log: () => {}, warn: () => {}, error: () => {}},
    setTimeout: (callback) => callback(),
  });
  return module.exports;
}

const {isPublishableMovie} = loadModule("services/movie_publisher.js", {
  "firebase-admin": {},
  "./movie_sheet": {},
});

test("EIGA retains noimg movies so TMDB can supply their posters", async () => {
  const {fetchRunningFromEIGA} = loadModule("countries/movie_jp.js", {
    axios: {get: async () => ({status: 200, data: `
      <section><div class="list-block">
        <div class="img-box"><a><img alt="映画" src="https://eiga.k-img.com/images/movie/noimg.jpg"></a></div>
        <small class="time">8月25日公開</small>
      </div></section>`})},
  });
  const movies = await fetchRunningFromEIGA();
  assert.equal(movies.length, 1);
  assert.equal(movies[0].localTitle, "映画");
  assert.equal(movies[0].batch, false);
});

test("TMDB replaces noimg; missing TMDB posters exclude only unusable movies", async () => {
  const {processBatch} = loadModule("services/utils.js", {
    "firebase-admin": {},
    "./movie_publisher": {},
    "./tmdb": {
      searchMovieInfoByTitle: async (country, title) => {
        assert.equal(country, "ja-JP");
        if (title === "unmatched") return null;
        return {poster_path: title === "replacement" ? "/real.jpg" : null,
          trailerLink: "https://youtube.com/watch?v=example"};
      },
    },
  });
  const movies = ["replacement", "missing", "unmatched", "original"].map((localTitle) => ({
    localTitle,
    posterUrl: localTitle === "original" ? "https://eiga.example/real.jpg" : "https://eiga.example/NOIMG.jpg",
    trailerUrl: "https://youtube.com/watch?v=example",
    batch: false,
  }));
  const result = await processBatch("ja-JP", movies, 0, Date.now());
  assert.equal(result[0].posterUrl, "https://image.tmdb.org/t/p/w600_and_h900_bestv2/real.jpg");
  assert.deepEqual(result.filter(isPublishableMovie).map((movie) => movie.localTitle), ["replacement", "original"]);
});

test("publishing rejects noimg anywhere in a URL, ignoring case", () => {
  for (const posterUrl of ["https://example.com/noimg.png", "https://example.com/NoImg/1.jpg", "https://example.com/image?name=NOIMG", "", "ERR404"]) {
    assert.equal(isPublishableMovie({posterUrl, trailerUrl: "https://youtube.com/watch?v=example"}), false);
  }
  assert.equal(isPublishableMovie({posterUrl: "https://example.com/real.jpg", trailerUrl: ""}), false);
});
