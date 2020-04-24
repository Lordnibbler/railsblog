import 'photoswipe/dist/photoswipe.css'
import 'photoswipe/dist/default-skin/default-skin.css'
import PhotoSwipe from 'photoswipe';
import PhotoSwipeUI_Default from 'photoswipe/dist/photoswipe-ui-default';

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

  // TODO: move me to a separate JS file
  // photoswipe
  var pswpElement = document.querySelectorAll('.pswp')[0];
  // build items array
  var items = [
    {
      src: 'https://placekitten.com/600/400',
      w: 600,
      h: 400
    },
    {
      src: 'https://farm2.staticflickr.com/1043/5186867718_06b2e9e551_b.jpg',
      w: 964,
      h: 1024
    },
    {
      src: 'https://farm7.staticflickr.com/6175/6176698785_7dee72237e_b.jpg',
      w: 1024,
      h: 683
    }
  ];

  // define options (if needed)
  var options = {
    // optionName: 'option value'
    // for example:
    index: 0 // start at first slide
  };

  // Initializes and opens PhotoSwipe
  var gallery = new PhotoSwipe( pswpElement, PhotoSwipeUI_Default, items, options);
  gallery.init();

});
