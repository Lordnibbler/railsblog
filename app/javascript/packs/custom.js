var fitvids = require('fitvids');

$(document).on('turbolinks:load', function() {
  // ensure videos fit width of page
  fitvids('#main');

  // flash auto-hiding
  $('.flash').on('click', function(event) {
    $(this).slideUp();
  });
});
