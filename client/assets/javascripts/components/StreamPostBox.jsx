import React from 'react';
import StreamPostActions from '../actions/StreamPostActions';
import StreamPostStore from '../stores/StreamPostStore';
import StreamPost from './StreamPost';

const StreamPostBox = React.createClass({
  displayName: 'StreamPostBox',

  propTypes: {
    url: React.PropTypes.string.isRequired
  },

  getStoreState() {
    return {
      posts: StreamPostStore.getState()
    };
  },

  getInitialState() {
    return this.getStoreState();
  },

  componentDidMount() {
    StreamPostStore.listen(this.onChange);
    StreamPostActions.fetchStreamPosts(this.props.url, true);
  },

  componentWillUnmount() {
    StreamPostStore.unlisten(this.onChange);
  },

  onChange() {
    this.setState(this.getStoreState());
  },

  renderStreamPosts() {
    return this.state.posts.posts.map(function (post) {
      return <StreamPost key={post.created_at} post={post} />;
    });
  },

  render() {
    return(
      <div className='stream-post-container'>
        {this.renderStreamPosts()}
      </div>
    );
  }
});

export default StreamPostBox;
