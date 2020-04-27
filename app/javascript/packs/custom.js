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
