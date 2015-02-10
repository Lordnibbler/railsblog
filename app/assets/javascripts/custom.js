$(function(){
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
});

// activate disqus
var disqus = {
  'activate' : true,
  'shortname' : 'benradler'
};
