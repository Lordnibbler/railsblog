import $ from 'jquery';
import React from 'react';
import CommentBox from './components/CommentBox';
import StreamPostBox from './components/StreamPostBox';

$(function onLoad() {
  function renderStream() {
    if ($('#stream').length > 0) {
      React.render(
        <StreamPostBox url='api/v1/stream' />,
        document.getElementById('stream')
      )
    };
  }

  function renderComments() {
    if ($('#content').length > 0) {
      React.render(
        <div>
          <CommentBox url='comments.json' pollInterval={5000}/>

          <div className='container'>
            <a href='http://www.railsonmaui.com'>
              <h3 className='open-sans-light'>
                <div className='logo'/>
                Example of styling using image-url and Open Sans Light custom font
              </h3>
            </a>
            <a href='https://twitter.com/railsonmaui'>
              <div className='twitter-image'/>
              Rails On Maui on Twitter
            </a>
          </div>
        </div>,
        document.getElementById('content')
      );
    }
  }

  renderStream();
  renderComments();

  // Next part is to make this work with turbo-links
  $(document).on('page:change', () => {
    renderStream();
    renderComments();
  });
});