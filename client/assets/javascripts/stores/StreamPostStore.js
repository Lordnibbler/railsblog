import alt from '../FluxAlt';
import React from 'react/addons';
import StreamPostActions from '../actions/StreamPostActions';

class StreamPostStore {
    constructor() {
        this.posts = [];
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

    handleUpdateStreamPosts(posts) {
        this.posts = posts;
        this.errorMessage = null;
    }

    handleUpdateStreamPostsError(errorMessage) {
        this.errorMessage = errorMessage;
    }
}

export default alt.createStore(StreamPostStore, 'StreamPostStore');
