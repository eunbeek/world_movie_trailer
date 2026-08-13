const {google} = require("googleapis");
const youtube = google.youtube("v3");

/**
 * Fetches the first video ID from YouTube using the YouTube Data API.
 * @param {string} query - The search query.
 * @param {string} country - The region code.
 * @return {Promise<string>} - A promise that resolves to the first video ID.
 */
async function fetchFirstYouTubeVideoId(query, country) {
  try {
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
    console.log(response.data.items[0].id.videoId);
    return response.data.items[0].id.videoId;
  } catch (error) {
    console.error("Error fetching YouTube video ID:", error);
    throw error;
  }
}

module.exports = {
  fetchFirstYouTubeVideoId,
};
