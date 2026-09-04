const assert = require("node:assert/strict");
const test = require("node:test");

const {
  buildSpecialDataRow,
  buildSpecialConceptUpdates,
  buildSpecialTitleUpdates,
  localizeSpecialCountry,
  parseSpecialSourceRow,
} = require("../services/movie_sheet");

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

test("Special source uses the new country and localized-title columns", () => {
  const movie = parseSpecialSourceRow([
    "696506",
    "1",
    "osYpGSz_0i4",
    "2025",
    "Korea",
    "Bong Joon-Ho",
    "미키 17",
    "Mickey 17",
    "ミッキー17",
    "编号17",
    "米奇17號",
    "Mickey 17 FR",
    "Mickey 17 DE",
    "Mickey 17 ES",
    "मिकी 17",
    "มิกกี้ 17",
    "이 주의 감독",
    "Director of the Week",
    "今週の監督",
    "本周导演",
    "本週導演",
    "Réalisateur de la semaine",
    "Regisseur der Woche",
    "Director de la semana",
    "सप्ताह के निर्देशक",
    "ผู้กำกับประจำสัปดาห์",
  ]);

  assert.equal(movie.country, "Korea");
  assert.equal(movie.special, "Director of the Week");
  assert.equal(movie.source, "Bong Joon-Ho");
  assert.equal(movie.localTitle, "Mickey 17");
  assert.equal(movie.originSource.title, "Mickey 17");
  assert.equal(movie.originSource.country, "Korea");
  assert.equal(movie.translations.ko.title, "미키 17");
  assert.equal(movie.translations.de.title, "Mickey 17 DE");
  assert.equal(movie.translations.es.title, "Mickey 17 ES");
  assert.equal(movie.translations.ko.concept, "이 주의 감독");
  assert.equal(movie.translations.en.concept, "Director of the Week");

  const updates = buildSpecialTitleUpdates([movie], 4);
  const byRange = Object.fromEntries(updates.map((update) =>
    [update.range, update.values]));
  assert.deepEqual(byRange["'SPECIAL_DATA'!N4:N4"], [["미키 17"]]);
  assert.deepEqual(byRange["'SPECIAL_DATA'!R4:R4"], [["Mickey 17"]]);
  assert.deepEqual(byRange["'SPECIAL_DATA'!AH4:AH4"], [["Mickey 17 FR"]]);
  assert.deepEqual(byRange["'SPECIAL_DATA'!AL4:AL4"], [["Mickey 17 ES"]]);
  assert.deepEqual(byRange["'SPECIAL_DATA'!AP4:AP4"], [["Mickey 17 DE"]]);

  const conceptUpdates = buildSpecialConceptUpdates([movie], 4);
  const conceptsByRange = Object.fromEntries(conceptUpdates.map((update) =>
    [update.range, update.values]));
  assert.deepEqual(conceptsByRange["'SPECIAL_DATA'!M4:M4"], [["이 주의 감독"]]);
  assert.deepEqual(
      conceptsByRange["'SPECIAL_DATA'!Q4:Q4"],
      [["Director of the Week"]],
  );
  assert.deepEqual(
      conceptsByRange["'SPECIAL_DATA'!U4:U4"],
      [["今週の監督"]],
  );
});

test("Special countries support aliases and multi-country values", () => {
  assert.equal(localizeSpecialCountry("Korea", "ko"), "대한민국");
  assert.equal(
      localizeSpecialCountry("U.S. & Spain", "ko"),
      "미국 · 스페인",
  );
  assert.equal(
      localizeSpecialCountry("Ireland / U.K. / U.S.", "en"),
      "Ireland · United Kingdom · United States",
  );
  assert.equal(
      localizeSpecialCountry("British-American", "es"),
      "Reino Unido · Estados Unidos",
  );
});
