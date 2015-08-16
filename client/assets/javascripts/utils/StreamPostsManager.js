import $ from 'jquery';

const STREAM_API_URL = 'api/v1/stream';
const FLICKR_API_URL = 'api/v1/stream/flickr';
const INSTAGRAM_API_URL = 'api/v1/stream/instagram';

const StreamPostsManager = {

  fetchStreamPosts() {
    return this._get(STREAM_API_URL);
  },

  fetchInstagramPosts() {
    return this._get(INSTAGRAM_API_URL);
  },

  fetchFlickrPosts() {
    return this._get(FLICKR_API_URL);
  },

  /**
   * GET {url} using AJAX call.
   *
   * @param {String} url - API endpoint to issue GET request to
   * @returns {Deferred} - jqXHR result of ajax call.
   */
  _get(url) {
    return $.ajax({
      url: url,
      dataType: 'json'
    });
  }
};

export default StreamPostsManager;
