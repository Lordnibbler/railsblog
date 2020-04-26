import 'photoswipe/dist/photoswipe.css'
import 'photoswipe/dist/default-skin/default-skin.css'
import PhotoSwipe from 'photoswipe';
import PhotoSwipeUI_Default from 'photoswipe/dist/photoswipe-ui-default';
import InfiniteScroll from 'infinite-scroll';
import Masonry from 'masonry-layout';
import imagesLoaded from 'imagesloaded';

var fitvids = require('fitvids');

$(document).on('turbolinks:load', function() {
  // main menu expander for smaller displays
  $('.expander').click(function() {
    $(this).toggleClass('expanded');
    $('.main-menu').toggleClass('expanded');
  });

  // ensure videos fit width of page
  fitvids('.site');

  // flash auto-hiding
  $('.flash').on('click', function(event) {
    $(this).slideUp();
  });
});
