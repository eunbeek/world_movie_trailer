const assert = require("node:assert/strict");
const test = require("node:test");

const {buildSpecialDataRow} = require("../services/movie_sheet");

test("Special source omits country and keeps credits in column L", () => {
  const row = buildSpecialDataRow({
    id: "special:1:tmdb:123",
    tid: "123",
    period: 1,
    sourceType: "tmdb",
    posterUrl: "poster",
    trailerUrl: "trailer",
    runtime: 120,
    year: "2026",
    special: "Festival Winners",
    country: "US",
    source: "Director Name",
    originSource: {
      concept: "Festival Winners",
      title: "Movie",
      overview: "Overview",
      country: "US",
      credits: "Director Name",
    },
  });

  assert.equal(row.length, 12);
  assert.deepEqual(row.slice(8), [
    "Festival Winners",
    "Movie",
    "Overview",
    "Director Name",
  ]);
  assert.ok(!row.includes("US"));
});
