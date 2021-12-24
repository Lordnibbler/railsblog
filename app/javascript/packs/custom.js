import fitvids from 'fitvids';

$(document).on('turbo:load', function() {
  // ensure videos fit width of page
  fitvids('#main');

  // flash auto-hiding
  $('.flash').on('click', function(event) {
    $(this).slideUp();
  });

  function desktopNavTransparencyHandler () {
    //
    // when page is scrolled down >=100px, make the navigation 90% transparent
    // when page is scrolled up <100px, make the navigation 100% transparent (home) or opaque (all other pages)
    //
    let notScrolledClass // class when page is scrolled to top
    let scrolledClass // class when page is scrolled past 100px
    if (window.location.pathname == "/") {
      notScrolledClass = "bg-primary/0"
      scrolledClass = "bg-primary/90"
    } else {
      notScrolledClass = "bg-primary"
      scrolledClass = "bg-primary/90"
    }

    // event listener logic, when page scrolls past 100px y-axis, switch CSS background
    let navElement = document.querySelector(".desktop-nav");
    if (this.scrollY > 100) {
      navElement.classList.replace(notScrolledClass, scrolledClass)
    } else {
      navElement.classList.replace(scrolledClass, notScrolledClass)
    }
  }

  window.addEventListener("scroll", desktopNavTransparencyHandler, false)
});
