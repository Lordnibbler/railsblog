import alt from '../FluxAlt';
import React from 'react/addons';
import StreamPostActions from '../actions/StreamPostActions';

class StreamPostStore {
  constructor() {
    this.posts = [];
    this.pagination = {};
    this.errorMessage = null;
    this.bindListeners({
      handleFetchStreamPosts: StreamPostActions.FETCH_STREAM_POSTS,
      handleUpdateStreamPosts: StreamPostActions.UPDATE_STREAM_POSTS,
      handleUpdateStreamPostsError: StreamPostActions.UPDATE_STREAM_POSTS_ERROR
    });
  }

  handleFetchStreamPosts() {
    return false;
  }

  /**
   * update posts store state to newest posts ordered by created_at
   *
   * @param {Array<Object>} posts - array of post objects to add to the store state
   * @return {void}
   */
  handleUpdateStreamPosts(posts) {
    this.pagination[posts.source] = posts.page;
    // turn off sorting by created_at for now, as it makes for weird UX
    // this.posts = this.posts.concat(posts.posts).sort(function(a, b) {
    //   return parseInt(b.created_at) - parseInt(a.created_at);
    // });
    this.posts = this.posts.concat(posts.posts);
    this.errorMessage = null;
  }

  handleUpdateStreamPostsError(errorMessage) {
    this.errorMessage = errorMessage;
  }
}

export default alt.createStore(StreamPostStore, 'StreamPostStore');
