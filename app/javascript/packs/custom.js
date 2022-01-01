import fitvids from 'fitvids';

$(document).on('turbo:load', function() {
  // ensure videos fit width of page
  fitvids('#main');

  // flash auto-hiding
  $('.flash').on('click', function(event) {
    $(this).slideUp();
  });

  function navTransparencyHandler() {
    //
    // when page is scrolled down >=100px, make the navigation 95% transparent
    // when page is scrolled up <100px, make the navigation 100% transparent (home) or opaque (all other pages)
    //
    let notScrolledClasses // class when page is scrolled to top
    let scrolledClasses = ["bg-primary/95", "dark:bg-primary-50/95"] // class when page is scrolled past 100px
    if (window.location.pathname === "/") {
      notScrolledClasses = ["bg-primary/0", "dark:bg-primary-50/0"]
    } else {
      notScrolledClasses = ["bg-primary", "dark:bg-primary-50"]
    }

    // event listener logic, when page scrolls past 100px y-axis, switch CSS background
    let navElement = document.querySelector(".desktop-nav");
    if (this.scrollY > 100 || this.scrollY === undefined) {
      navElement.classList.add(...scrolledClasses)
      navElement.classList.remove(...notScrolledClasses)
    } else {
      navElement.classList.add(...notScrolledClasses)
      navElement.classList.remove(...scrolledClasses)
    }
  }

  // run once on homepage load to ensure classes are set appropriately,
  // in case of linking straight to homepage on an anchor (hash)
  if (window.location.pathname === "/" && window.location.hash) {
    navTransparencyHandler.bind(this)()
  }

  // when page scrolls, update nav transparency as needed
  window.addEventListener("scroll", navTransparencyHandler, false)
});
