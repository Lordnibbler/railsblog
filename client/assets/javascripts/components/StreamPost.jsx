import React from 'react';

const StreamPost = React.createClass({
    displayName: 'StreamPost',

    propTypes: {
        post: React.PropTypes.object.isRequired
    },

    render() {
        return (
            <img className='stream-post' src={this.props.post.url_thumbnail} />
        );
    },
});

export default StreamPost;
