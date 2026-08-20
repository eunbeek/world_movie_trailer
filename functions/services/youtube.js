const {google} = require("googleapis");
const youtube = google.youtube("v3");
const youtubeSearchCache = new Map();

/**
 * Fetches the first video ID from YouTube using the YouTube Data API.
 * @param {string} query - The search query.
 * @param {string} country - The region code.
 * @return {Promise<string>} - A promise that resolves to the first video ID.
 */
async function fetchFirstYouTubeVideoId(query, country) {
  try {
    const normalizedCountry = String(country || "").toUpperCase();
    const normalizedQuery = String(query || "").trim().toLowerCase();
    const cacheKey = `${normalizedCountry}:${normalizedQuery}`;
    if (youtubeSearchCache.has(cacheKey)) {
      console.log(`YouTube cache hit: ${cacheKey}`);
      return youtubeSearchCache.get(cacheKey);
    }
    const apiKey = process.env.YOUTUBE_API_KEY;
    if (!apiKey) throw new Error("YOUTUBE_API_KEY secret is not configured.");
    const response = await youtube.search.list({
      q: query,
      part: "id",
      maxResults: 1,
      regionCode: country,
      key: apiKey,
    });

    if (response.data.items.length === 0) {
      throw new Error("No video ID found");
    }
    const videoId = response.data.items[0].id.videoId;
    youtubeSearchCache.set(cacheKey, videoId);
    console.log(videoId);
    return videoId;
  } catch (error) {
    console.error("Error fetching YouTube video ID:", error);
    throw error;
  }
}

module.exports = {
  fetchFirstYouTubeVideoId,
};
