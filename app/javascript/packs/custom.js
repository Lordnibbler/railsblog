import fitvids from 'fitvids';

$(document).on('turbo:load', function() {
  // ensure videos fit width of page
  fitvids('#main');

  // flash auto-hiding
  $('.flash').on('click', function(event) {
    $(this).slideUp();
  });

  function desktopNavTransparencyHandler() {
    console.log("woot", this.scrollY)
    //
    // when page is scrolled down >=100px, make the navigation 95% transparent
    // when page is scrolled up <100px, make the navigation 100% transparent (home) or opaque (all other pages)
    //
    let notScrolledClass // class when page is scrolled to top
    let scrolledClass // class when page is scrolled past 100px
    if (window.location.pathname === "/") {
      notScrolledClass = "bg-primary/0"
      scrolledClass = "bg-primary/95"
    } else {
      notScrolledClass = "bg-primary"
      scrolledClass = "bg-primary/95"
    }

    // event listener logic, when page scrolls past 100px y-axis, switch CSS background
    let navElement = document.querySelector(".desktop-nav");
    if (this.scrollY > 100 || this.scrollY === undefined) {
      console.log(">100")
      navElement.classList.replace(notScrolledClass, scrolledClass)
    } else {
      console.log("<100")
      navElement.classList.replace(scrolledClass, notScrolledClass)
    }
  }

  // run once on homepage load to ensure classes are set appropriately,
  // in case of linking straight to homepage on an anchor (hash)
  if (window.location.pathname === "/" && window.location.hash) {
    desktopNavTransparencyHandler.bind(this)()
  }

  window.addEventListener("scroll", desktopNavTransparencyHandler, false)
});
