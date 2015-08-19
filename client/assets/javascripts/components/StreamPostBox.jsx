import React from 'react';
import StreamPostActions from '../actions/StreamPostActions';
import StreamPostStore from '../stores/StreamPostStore';
import StreamPost from './StreamPost';
import MasonryComponent from 'react-masonry-component'
const Masonry = MasonryComponent(React);

const StreamPostBox = React.createClass({
  displayName: 'StreamPostBox',

  propTypes: {
    // url: React.PropTypes.string.isRequired
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
    StreamPostActions.fetchStreamPosts(true);
  },

  componentWillUnmount() {
    StreamPostStore.unlisten(this.onChange);
  },

  onChange() {
    this.setState(this.getStoreState());
  },

  loadMore() {
    // console.log(this.state.posts.pagination)
    StreamPostActions.fetchStreamPosts(this.state.posts.pagination);
  },

  /**
   * return a StreamPost for each post in store's state
   * @return {Array<StreamPost>}
   */
  render() {
    var childElements = this.state.posts.posts.map(function (post) {
      return <StreamPost key={post.key} post={post} />;
    });

    var masonryOptions = {
      transitionDuration: 0
    };

    return(
      <div>
        <Masonry
          className={'stream-post-container'} // default ''
          elementType={'div'} // default 'div'
          options={masonryOptions} // default {}
          disableImagesLoaded={false} // default false
        >
          {childElements}
        </Masonry>
        <button className='load-more' onClick={this.loadMore}>Load More</button>
      </div>
    );
  }
});

export default StreamPostBox;
