import $ from 'jquery';

const STREAM_API_URL = 'api/v1/stream';
const FLICKR_API_URL = 'api/v1/stream/flickr';
const INSTAGRAM_API_URL = 'api/v1/stream/instagram';

const StreamPostsManager = {
  /**
   * Retrieve stream posts from server using AJAX call.
   *
   * @param {String} url - Url of server to retrieve comments.
   * @returns {Deferred} - jqXHR result of ajax call.
   */
  fetchStreamPosts() {
    return $.ajax({
      url: STREAM_API_URL,
      dataType: 'json'
    });
  },

  fetchInstagramPosts() {
    return $.ajax({
      url: INSTAGRAM_API_URL,
      dataType: 'json'
    });
  },

  fetchFlickrPosts() {
    return $.ajax({
      url: FLICKR_API_URL,
      dataType: 'json'
    });
  }
};

export default StreamPostsManager;
