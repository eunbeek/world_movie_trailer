const assert = require("node:assert/strict");
const test = require("node:test");

const {parseQuoteSourceRow} = require("../features/quote/special");

test("Quotes source reads all ten language pairs", () => {
  const quote = parseQuoteSourceRow([
    "1",
    "English quote",
    "English movie",
    "한국어 명언",
    "한국 영화",
    "日本語の名言",
    "日本映画",
    "简体名言",
    "简体电影",
    "繁體名言",
    "繁體電影",
    "Citation française",
    "Film français",
    "Deutsches Zitat",
    "Deutscher Film",
    "Cita española",
    "Película española",
    "हिंदी उद्धरण",
    "हिंदी फ़िल्म",
    "คำคมไทย",
    "หนังไทย",
  ], "2026-09-03T00:00:00.000Z");

  assert.equal(quote.quoteEN, "English quote");
  assert.equal(quote.quoteKR, "한국어 명언");
  assert.equal(quote.quoteJP, "日本語の名言");
  assert.deepEqual(quote.translations.zh, {
    quote: "简体名言",
    movie: "简体电影",
  });
  assert.deepEqual(quote.translations.tw, {
    quote: "繁體名言",
    movie: "繁體電影",
  });
  assert.equal(quote.translations.fr.movie, "Film français");
  assert.equal(quote.translations.de.quote, "Deutsches Zitat");
  assert.equal(quote.translations.es.movie, "Película española");
  assert.equal(quote.translations.hi.quote, "हिंदी उद्धरण");
  assert.equal(quote.translations.th.movie, "หนังไทย");
});
