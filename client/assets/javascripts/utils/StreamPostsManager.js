import $ from 'jquery';

const StreamPostsManager = {
    /**
     * Retrieve stream posts from server using AJAX call.
     *
     * @param {String} url - Url of server to retrieve comments.
     * @returns {Deferred} - jqXHR result of ajax call.
     */
        fetchStreamPosts(url) {
        return $.ajax({
            url: url,
            dataType: 'json'
        });
    }
};

export default StreamPostsManager;
