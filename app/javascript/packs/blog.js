import fitvids from 'fitvids';

$(document).on('turbo:load', function() {
  // ensure videos fit full width of page
  fitvids('#main');
});