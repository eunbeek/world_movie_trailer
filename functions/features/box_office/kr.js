/* eslint-disable max-len, valid-jsdoc */
const axios = require("axios");

const KOBIS_WEEKLY_API_URL = "https://www.kobis.or.kr/kobisopenapi/webservice/rest/boxoffice/searchWeeklyBoxOfficeList.json";

/** Converts YYYYMMDD (or another date-like string) to YYYY-MM-DD. */
function formatKobisDate(value) {
  const digits = String(value || "").replace(/\D/g, "");
  return digits.length === 8 ? `${digits.slice(0, 4)}-${digits.slice(4, 6)}-${digits.slice(6, 8)}` : "";
}

/** Returns the most recent completed Sunday in Korea as YYYYMMDD. */
function getLatestKoreanSunday(now = new Date()) {
  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone: "Asia/Seoul",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    weekday: "short",
  }).formatToParts(now).reduce((result, part) => {
    result[part.type] = part.value;
    return result;
  }, {});
  const weekdayIndex = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"].indexOf(parts.weekday);
  const koreanDate = new Date(Date.UTC(Number(parts.year), Number(parts.month) - 1, Number(parts.day)));
  koreanDate.setUTCDate(koreanDate.getUTCDate() - weekdayIndex);
  return koreanDate.toISOString().slice(0, 10).replace(/-/g, "");
}

/** Calculates the displayed number of release weeks. */
function getReleaseWeeks(releaseDate, weekEndDate) {
  const released = new Date(`${releaseDate}T00:00:00Z`);
  const ended = new Date(`${weekEndDate}T00:00:00Z`);
  if (Number.isNaN(released.getTime()) || Number.isNaN(ended.getTime())) return "";
  return String(Math.max(1, Math.ceil((ended - released + 86400000) / 604800000)));
}

/** Parses the KOBIS showRange value into ISO start/end dates. */
function parseShowRange(showRange, targetDate) {
  const dates = String(showRange || "").match(/\d{4}\D?\d{2}\D?\d{2}/g) || [];
  const weekEndDate = formatKobisDate(dates[1] || dates[0] || targetDate);
  const end = new Date(`${weekEndDate}T00:00:00Z`);
  if (Number.isNaN(end.getTime())) return {weekStartDate: "", weekEndDate: ""};
  end.setUTCDate(end.getUTCDate() - 6);
  return {weekStartDate: end.toISOString().slice(0, 10), weekEndDate};
}

/** Maps a KOBIS Open API item to the shared Box Office model. */
function mapKobisMovie(item, dateRange) {
  const rank = String(item.rank || "");
  const isNewThisWeek = item.rankOldAndNew === "NEW";
  const rankMovement = Number.parseInt(item.rankInten, 10);
  const priorRank = Number.parseInt(rank, 10) + (Number.isInteger(rankMovement) ? rankMovement : 0);
  const releaseDate = formatKobisDate(item.openDt);

  return {
    rank,
    lastRank: isNewThisWeek ? "-" : String(Math.max(1, priorRank)),
    localTitle: item.movieNm || "",
    releaseDate,
    gross: item.salesAmt || "",
    percentChange: item.salesShare || "",
    theaters: item.scrnCnt || "",
    theaterChange: "",
    perTheaterGross: "",
    totalGross: item.salesAcc || "",
    weeks: getReleaseWeeks(releaseDate, dateRange.weekEndDate),
    distributor: "",
    isNewThisWeek,
    weekStartDate: dateRange.weekStartDate,
    weekEndDate: dateRange.weekEndDate,
    kobisMovieCode: item.movieCd || "",
    salesChange: item.salesChange || "",
    audience: item.audiCnt || "",
    audienceChange: item.audiChange || "",
    totalAudience: item.audiAcc || "",
    showCount: item.showCnt || "",
    source: "kobis-open-api",
    batch: false,
  };
}

/** Fetches the latest completed weekly Korean box office from KOBIS Open API. */
async function fetchMovieListFromKobis(targetDate = getLatestKoreanSunday()) {
  const apiKey = process.env.KOBIS_API_KEY;
  if (!apiKey) throw new Error("KOBIS_API_KEY secret is not configured.");

  const response = await axios.get(KOBIS_WEEKLY_API_URL, {
    timeout: 30000,
    params: {key: apiKey, targetDt: targetDate, weekGb: "0"},
  });
  const result = response.data && response.data.boxOfficeResult;
  const items = result && result.weeklyBoxOfficeList;
  if (!Array.isArray(items) || items.length === 0) {
    const fault = response.data && response.data.faultInfo;
    throw new Error(fault && fault.message ? `KOBIS API: ${fault.message}` : "KOBIS Open API returned no weekly movie rows.");
  }

  const dateRange = parseShowRange(result.showRange, targetDate);
  const movies = items.map((item) => mapKobisMovie(item, dateRange)).filter((movie) => movie.rank && movie.localTitle);
  console.log(`KOBIS Open API returned ${movies.length} movies for ${targetDate} (${result.showRange || "range unavailable"}).`);
  return movies;
}

module.exports = {
  fetchMovieListFromKobis,
  formatKobisDate,
  getLatestKoreanSunday,
  getReleaseWeeks,
  mapKobisMovie,
  parseShowRange,
};
