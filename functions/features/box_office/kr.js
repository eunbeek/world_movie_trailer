/* eslint-disable max-len, valid-jsdoc */
const axios = require("axios");
const cheerio = require("cheerio");

const KOBIS_WEEKLY_API_URL = "https://www.kobis.or.kr/kobisopenapi/webservice/rest/boxoffice/searchWeeklyBoxOfficeList.json";
const KOBIS_WEEKLY_PAGE_URL = "https://www.kobis.or.kr/kobis/business/stat/boxs/findWeeklyBoxOfficeList.do";
const KOBIS_WEB_MAX_RANK = 50;
const KOBIS_WEB_ADDITIONAL_COUNT = 40;

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

/** Returns the first compact text value from a KOBIS table cell. */
function firstCellValue(cell) {
  return cell.text().trim().split(/\s+/)[0] || "";
}

/** Removes display separators from a numeric KOBIS table value. */
function normalizeNumber(value) {
  return String(value || "").replace(/,/g, "").trim();
}

/** Calculates the preceding rank from KOBIS movement markup. */
function getPreviousWebRank(rank, movementClass, movementText) {
  if (movementClass.includes("ico_new")) return "-";
  const movement = Number.parseInt(String(movementText || "").replace(/\D/g, ""), 10);
  if (!Number.isInteger(movement)) return String(rank);
  if (movementClass.includes("ico_rise")) return String(rank + movement);
  if (movementClass.includes("ico_fall")) return String(Math.max(1, rank - movement));
  return String(rank);
}

/** Parses ranks 11 through maxRank from the KOBIS tbody2_0 table. */
function parseKobisWebRows(html, dateRange, maxRank = KOBIS_WEB_MAX_RANK) {
  const $ = cheerio.load(html);
  const movies = [];

  $("#tbody2_0 tr").each((_, row) => {
    const cells = $(row).find("td");
    const rank = Number.parseInt(firstCellValue(cells.eq(0)), 10);
    if (!Number.isInteger(rank) || rank <= 10 || rank > maxRank) return;

    const titleLink = cells.eq(1).find("a[title]").first();
    const localTitle = String(titleLink.attr("title") || titleLink.text()).trim();
    if (!localTitle) return;
    const movement = cells.eq(1).find("span[class^='ico_']").first();
    const movementClass = movement.attr("class") || "";
    const movementText = movement.text().trim();
    const movieCodeMatch = String(titleLink.attr("onclick") || "").match(/'movie','(\d+)'/);
    const releaseDate = cells.eq(2).text().trim();
    const salesChangeText = cells.eq(5).text().trim();
    const audienceChangeText = cells.eq(8).text().trim();

    movies.push({
      rank: String(rank),
      lastRank: getPreviousWebRank(rank, movementClass, movementText),
      localTitle,
      releaseDate,
      gross: normalizeNumber(firstCellValue(cells.eq(3))),
      percentChange: firstCellValue(cells.eq(4)),
      theaters: normalizeNumber(firstCellValue(cells.eq(10))),
      theaterChange: "",
      perTheaterGross: "",
      totalGross: normalizeNumber(firstCellValue(cells.eq(6))),
      weeks: getReleaseWeeks(releaseDate, dateRange.weekEndDate),
      distributor: "",
      isNewThisWeek: movementClass.includes("ico_new"),
      weekStartDate: dateRange.weekStartDate,
      weekEndDate: dateRange.weekEndDate,
      kobisMovieCode: movieCodeMatch ? movieCodeMatch[1] : "",
      salesChange: normalizeNumber(firstCellValue($("<td>").text(salesChangeText))),
      audience: normalizeNumber(firstCellValue(cells.eq(7))),
      audienceChange: normalizeNumber(firstCellValue($("<td>").text(audienceChangeText))),
      totalAudience: normalizeNumber(firstCellValue(cells.eq(9))),
      showCount: normalizeNumber(firstCellValue(cells.eq(11))),
      source: "kobis-web",
      batch: false,
    });
  });

  return movies.sort((a, b) => Number(a.rank) - Number(b.rank));
}

/** Fetches additional weekly ranks from the public KOBIS statistics page. */
async function fetchAdditionalKobisWebRows(dateRange) {
  const headers = {
    "Accept-Language": "ko-KR,ko;q=0.9",
    "User-Agent": "Mozilla/5.0 (compatible; WorldMovieTrailer/2.0)",
  };
  const initialResponse = await axios.get(KOBIS_WEEKLY_PAGE_URL, {
    timeout: 30000,
    headers,
  });
  const $ = cheerio.load(initialResponse.data);
  const formData = new URLSearchParams();
  $("#searchForm").serializeArray().forEach(({name, value}) => {
    formData.set(name, value);
  });
  formData.set("loadEnd", "0");
  formData.set("searchType", "search");
  const cookie = (initialResponse.headers["set-cookie"] || [])
      .map((value) => value.split(";")[0])
      .join("; ");
  const response = await axios.post(KOBIS_WEEKLY_PAGE_URL, formData.toString(), {
    timeout: 30000,
    headers: {
      ...headers,
      "Content-Type": "application/x-www-form-urlencoded",
      "Cookie": cookie,
      "Referer": KOBIS_WEEKLY_PAGE_URL,
    },
  });
  const movies = parseKobisWebRows(response.data, dateRange);
  if (movies.length === 0) throw new Error("KOBIS tbody2_0 returned no additional ranks.");
  return movies;
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
  let additionalMovies = [];
  try {
    additionalMovies = await fetchAdditionalKobisWebRows(dateRange);
  } catch (error) {
    console.warn(`KOBIS web ranks unavailable; keeping API top 10: ${error.message}`);
  }
  const seenMovieCodes = new Set(movies.map((movie) => movie.kobisMovieCode).filter(Boolean));
  const seenTitles = new Set(movies.map((movie) => movie.localTitle.trim().toLowerCase()));
  const uniqueAdditionalMovies = additionalMovies.filter((movie) => {
    const title = movie.localTitle.trim().toLowerCase();
    if (seenMovieCodes.has(movie.kobisMovieCode) || seenTitles.has(title)) return false;
    if (movie.kobisMovieCode) seenMovieCodes.add(movie.kobisMovieCode);
    seenTitles.add(title);
    return true;
  }).slice(0, KOBIS_WEB_ADDITIONAL_COUNT).map((movie, index) => ({
    ...movie,
    rank: String(movies.length + index + 1),
  }));
  const merged = [...movies, ...uniqueAdditionalMovies];
  console.log(`KOBIS returned ${movies.length} API movies and ${uniqueAdditionalMovies.length} unique web movies for ${targetDate} (${result.showRange || "range unavailable"}).`);
  return merged;
}

module.exports = {
  fetchMovieListFromKobis,
  fetchAdditionalKobisWebRows,
  formatKobisDate,
  getLatestKoreanSunday,
  getPreviousWebRank,
  getReleaseWeeks,
  mapKobisMovie,
  normalizeNumber,
  parseShowRange,
  parseKobisWebRows,
};
