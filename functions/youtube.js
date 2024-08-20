const {google} = require("googleapis");
const youtube = google.youtube("v3");

/**
 * Fetches the first video ID from YouTube using the YouTube Data API.
 * @param {string} query - The search query.
 * @return {Promise<string>} - A promise that resolves to the first video ID.
 */
async function fetchFirstYouTubeVideoId(query) {
  try {
    const response = await youtube.search.list({
      q: query,
      part: "id",
      maxResults: 1,
      type: "video",
      key: "AIzaSyD5D-K3UTFbBr5aBwrHCzciDYjPaa4bi2I",
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
