const assert = require("node:assert/strict");
const test = require("node:test");

const {
  areTranslationsComplete,
  attachLocalizedCreditNames,
  isUsableTranslation,
  orderedCreditPeople,
  splitTranslatedCredits,
} = require("../services/movie_publisher");

const credits = {
  cast: [
    {id: 10, name: "Actor One", character: "One"},
    {id: 20, name: "Actor Two", character: "Two"},
  ],
  crew: [
    {id: 30, name: "Director One", job: "Director"},
    {id: 30, name: "Director One", job: "Writer"},
  ],
};

test("Credit roster keeps arbitrary people in stable order", () => {
  assert.deepEqual(
      orderedCreditPeople(credits).map((person) => person.id),
      [10, 20, 30],
  );
});

test("Credits support the stable delimiter and legacy commas", () => {
  assert.deepEqual(splitTranslatedCredits("배우 하나 ||| 배우 둘 ||| 감독 하나"),
      ["배우 하나", "배우 둘", "감독 하나"]);
  assert.deepEqual(splitTranslatedCredits("Actor One, Actor Two, Director One"),
      ["Actor One", "Actor Two", "Director One"]);
});

test("Localized credit names are keyed by stable TMDB person IDs", () => {
  const translations = attachLocalizedCreditNames({
    ko: {credits: "배우 하나 ||| 배우 둘 ||| 감독 하나"},
    ja: {credits: "人数不一致"},
  }, credits);

  assert.deepEqual(translations.ko.creditNames, {
    "10": "배우 하나",
    "20": "배우 둘",
    "30": "감독 하나",
  });
  assert.equal(translations.ja.creditNames, undefined);
});

test("Copied overview is incomplete outside the source language", () => {
  const koreanOverview = "충분히 긴 한국어 영화 소개가 번역되지 않고 원문 그대로 남아 있습니다.";
  assert.equal(isUsableTranslation(
      koreanOverview, koreanOverview, "overview", "ja", "ko"), false);
  assert.equal(isUsableTranslation(
      koreanOverview, koreanOverview, "overview", "ko", "ko"), true);
  assert.equal(isUsableTranslation(
      "日本語に翻訳された映画の紹介です。", koreanOverview,
      "overview", "ja", "ko"), true);
});

test("Translation completeness uses the country feed's source language", () => {
  const source = {
    title: "사진의 얼굴",
    overview: "충분히 긴 한국어 영화 소개가 번역되지 않고 원문 그대로 남아 있습니다.",
    country: "대한민국",
    credits: "감독 이름",
  };
  const translations = {
    ko: {...source},
    ja: {
      title: "写真の顔",
      overview: source.overview,
      country: "韓国",
      credits: "監督名",
    },
  };
  assert.equal(areTranslationsComplete(
      [{originSource: source, translations}], "kr"), false);
  translations.ja.overview = "日本語に翻訳された映画の紹介です。";
  assert.equal(areTranslationsComplete(
      [{originSource: source, translations}], "kr"), true);
});
