/* eslint-disable max-len */
const axios = require("axios");
const cheerio = require("cheerio");

/**
 * Fetches movie data from UGC
 * @return {Promise<Array>}
 * A promise that resolves to a list of movies from UGC.
 */
async function fetchMovieListFromMojo() {
  const movies = [];

  const getISOWeek = (date) => {
    const thursday = new Date(date.getTime());
    thursday.setDate(thursday.getDate() + (4 - (thursday.getDay() || 7))); // 목요일로 이동
    const yearStart = new Date(thursday.getFullYear(), 0, 1);
    const weekNumber = Math.ceil(((thursday - yearStart) / 86400000 + 1) / 7);
    return weekNumber;
  };

  // 현재 날짜와 이전 주 계산
  const now = new Date();
  const currentYear = now.getFullYear();
  let week = getISOWeek(now) - 1; // 현재 주에서 1을 빼서 이전 주 계산

  // 연도 경계 처리
  let targetYear = currentYear;
  if (week <= 0) {
    targetYear -= 1;
    const lastDayOfPrevYear = new Date(targetYear, 11, 31);
    week = getISOWeek(lastDayOfPrevYear); // 이전 해의 마지막 주
  }

  // 주차 형식 설정 (예: W01, W02 등)
  const formattedWeek = `W${week.toString().padStart(2, "0")}`;
  const mojoUrl = `https://www.boxofficemojo.com/weekend/${targetYear}${formattedWeek}/`;
  console.log(mojoUrl);
  try {
    const response = await axios.get(mojoUrl);
    const $ = cheerio.load(response.data);
    // 📌 1. `mojo-gutter` 클래스를 가진 첫 번째 `h4`에서 날짜 추출
    const headerText = $("h4.mojo-gutter").first().text().trim();
    console.log(`📢 Extracted Header Text: ${headerText}`);

    // 📌 2. 날짜 정규식 (월이 같을 경우와 다를 경우 처리)
    const dateRangeMatch = headerText.match(/([A-Za-z]+)\s(\d+)\s*-\s*([A-Za-z]*)\s*(\d+),\s(\d{4})/);

    let weekStartDate = "";
    let weekEndDate = "";

    if (dateRangeMatch) {
      console.log(`📢 Date Match Groups:`, dateRangeMatch);

      const startMonth = dateRangeMatch[1]; // February
      const startDay = dateRangeMatch[2]; // 7
      const endMonth = dateRangeMatch[3] || startMonth; // February (없으면 startMonth와 동일)
      const endDay = dateRangeMatch[4]; // 9
      const year = dateRangeMatch[5]; // 2025

      // 📌 3. 날짜 변환 (ISO 포맷)
      const startDate = new Date(`${startMonth} ${startDay}, ${year}`);
      const endDate = new Date(`${endMonth} ${endDay}, ${year}`);

      if (!isNaN(startDate) && !isNaN(endDate)) {
        weekStartDate = startDate.toISOString().split("T")[0];
        weekEndDate = endDate.toISOString().split("T")[0];
      } else {
        console.error("❌ Failed to parse dates correctly!");
      }

      console.log(`📅 Extracted Date Range: ${weekStartDate} - ${weekEndDate}`);
    } else {
      console.error("⚠️ Failed to extract date range from header.");
    }

    const movieRows = $("#table .mojo-body-table tr");

    movieRows.each((index, element) => {
      const cells = $(element).find("td"); // Select all `td` elements in the row

      // Skip rows that don't have data
      if (cells.length === 0) return;

      const movie = {
        rank: $(cells[0]).text().trim(), // Rank column
        lastRank: $(cells[1]).text().trim() || "-", // Last week's rank
        localTitle: $(cells[2]).find("a").text().trim() === "Bonhoeffer" ?
            "Bonhoeffer: Pastor. Spy. Assassin" :
            $(cells[2]).find("a").text().trim(), // Movie title
        gross: $(cells[3]).text().trim(), // Weekend Gross
        percentChange: $(cells[4]).text().trim(), // Percentage change
        theaters: $(cells[5]).text().trim(), // Number of theaters
        theaterChange: $(cells[6]).text().trim(), // Theater change
        perTheaterGross: $(cells[7]).text().trim(), // Per theater gross
        totalGross: $(cells[8]).text().trim(), // Total gross
        weeks: $(cells[9]).text().trim(), // Weeks in release
        distributor: $(cells[10]).text().trim(), // Distributor
        isNewThisWeek: $(element).hasClass("mojo-annotation-isNewThisWeek"), // New this week?
        weekStartDate: weekStartDate,
        weekEndDate: weekEndDate,
        source: "mojo",
        batch: false,
      };

      // Push to the movies array if the row contains valid data
      if (movie.rank && movie.localTitle) {
        movies.push(movie);
      }
    });
  } catch (err) {
    console.error("Error fetching from UGC:", err);
  }

  return movies;
}

module.exports = {
  fetchMovieListFromMojo,
};
