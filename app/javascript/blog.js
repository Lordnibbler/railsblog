import $ from 'jquery';
import fitvids from 'fitvids';

$(document).on('turbo:load', () => {
  // ensure videos fit full width of page
  fitvids('#main');
});
