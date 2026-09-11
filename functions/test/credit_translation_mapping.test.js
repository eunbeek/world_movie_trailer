const assert = require("node:assert/strict");
const test = require("node:test");

const {
  areTranslationsComplete,
  attachLocalizedCreditNames,
  isUsableTranslation,
  mergeTranslations,
  overviewSourceLanguage,
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

test("A missing translated title keeps a feed incomplete", () => {
  const source = {
    title: "オデュッセイア",
    overview: "翻訳完了を確認するために十分な長さを持つ日本語の映画紹介です。",
  };
  const translations = {
    ja: {...source},
    ko: {title: "", overview: "번역이 완료된 한국어 영화 소개입니다."},
  };
  assert.equal(areTranslationsComplete(
      [{originSource: source, translations}], "jp"), false);
});

test("Missing translations use previous values, then source text", () => {
  const source = {
    title: "オデュッセイア",
    overview: "翻訳される前の日本語の映画紹介です。",
    credits: "監督名",
  };
  const movie = {
    originSource: source,
    translations: {
      ko: {title: "", overview: "", credits: ""},
      en: {title: "", overview: "", credits: ""},
    },
  };
  const previous = {
    translations: {
      ko: {title: "오디세이아", overview: "기존 한국어 소개입니다.", credits: ""},
    },
  };

  const merged = mergeTranslations(movie, previous, "jp");
  assert.equal(merged.ko.title, "오디세이아");
  assert.equal(merged.ko.overview, "기존 한국어 소개입니다.");
  assert.equal(merged.ko.credits, source.credits);
  assert.equal(merged.en.title, source.title);
  assert.equal(merged.en.overview, source.overview);
});

test("English TMDB fallback is accepted as the effective source", () => {
  const englishOverview =
    "A sufficiently long English overview returned as a TMDB fallback.";
  const movie = {
    originSource: {overview: englishOverview},
    translations: {
      en: {overview: englishOverview},
      ko: {
        overview: "TMDB 대체 데이터를 번역한 한국어 영화 소개입니다.",
      },
      ja: {
        overview: "TMDBの代替データを翻訳した日本語の映画紹介です。",
      },
    },
  };
  assert.equal(overviewSourceLanguage(movie, "de"), "en");
});

test("One untranslated English cell does not redefine the source", () => {
  const germanOverview =
    "Dies ist eine ausreichend lange deutsche Filmbeschreibung.";
  const movie = {
    originSource: {overview: germanOverview},
    translations: {
      en: {overview: germanOverview},
      ko: {overview: germanOverview},
    },
  };
  assert.equal(overviewSourceLanguage(movie, "de"), "de");
});
