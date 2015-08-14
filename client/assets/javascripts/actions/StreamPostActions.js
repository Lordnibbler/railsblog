import alt from '../FluxAlt';
import StreamPostsManager from '../utils/StreamPostsManager';

class StreamPostActions {
    /**
     * Fetch stream posts from server.
     *
     * @param {String} url - Url used for remote request.
     * @param {Boolean} displaySpinner - Flag whether to show wait spinner
     * @return {void}
     */
    fetchStreamPosts(url, displaySpinner) {
        // @todo loading spinner
        // this.dispatch(displaySpinner);
        StreamPostsManager.fetchStreamPosts(url)
            .then((streamPosts) => this.actions.updateStreamPosts(streamPosts),
            (errorMessage) => this.actions.updateStreamPostsError(errorMessage));
    }

    /**
     * A new list of stream posts is available, refresh the store.
     *
     * @param {Array} stream posts - New stream posts to replace those in the store
     * @return {void}
     */
    updateStreamPosts(streamPosts) {
        this.dispatch(streamPosts);
    }

    /**
     * An error occurred while fetching stream posts, dispatch error message.
     *
     * @param {String} errorMessage - Error message received from server.
     * @return {void}
     */
    updateStreamPostsError(errorMessage) {
        this.dispatch(errorMessage);
    }
}

export default alt.createActions(StreamPostActions);