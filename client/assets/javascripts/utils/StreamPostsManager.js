import $ from 'jquery';

const STREAM_API_URL = 'api/v1/stream';
const FLICKR_API_URL = 'api/v1/stream/flickr';
const INSTAGRAM_API_URL = 'api/v1/stream/instagram';

const StreamPostsManager = {

  fetchInstagramPosts(pagination) {
    return this._get(INSTAGRAM_API_URL, { page: pagination.instagram });
  },

  fetchFlickrPosts(pagination) {
    return this._get(FLICKR_API_URL, { page: pagination.flickr });
  },

  /**
   * GET {url} using AJAX call.
   *
   * @param {String} url - API endpoint to issue GET request to
   * @returns {Deferred} - jqXHR result of ajax call.
   */
  _get(url, body = '') {
    return $.ajax({
      url: url,
      dataType: 'json',
      data: body
    });
  }
};

export default StreamPostsManager;
