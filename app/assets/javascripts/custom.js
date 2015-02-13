// ensure client-side-validations gem runs on turbolinks page load
$(document).on('page:change', function() {
  // collapsible mobile navigation menu
  $('.expander').click(function() {
    $(this).toggleClass('expanded');
    $('.main-menu').toggleClass('expanded');
  });

  // ensure videos fit width of page
  $('.site').fitVids();

  // flash hiding
  $('.flash').on('click', function(event) {
    $(this).slideUp();
  });

  // enable client-side-validations
  $('form[data-validate]').validate();
});

// activate disqus
var disqus = {
  'activate' : true,
  'shortname' : 'benradler'
};
