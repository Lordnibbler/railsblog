import fitvids from 'fitvids';

$(document).on('turbo:load', function() {
  // ensure videos fit width of page
  fitvids('#main');

  // flash auto-hiding
  $('.flash').on('click', function(event) {
    $(this).slideUp();
  });

  function changeCss () {

    var bodyElement = document.querySelector("body");
    var navElement = document.querySelector(".desktop-nav");
    if (this.scrollY > 500) {
      console.log("changeCss - going NOT transparent")
      navElement.classList.remove("bg-primary/0")
      navElement.classList.add("bg-primary/90")
    } else {
      console.log("changeCss - going transparent")
      navElement.classList.remove("bg-primary/90")
      navElement.classList.add("bg-primary/0")
    }
    // this.scrollY > 500 ? navElement.style.opacity = 0.0 : navElement.style.opacity = 1;
  }

  window.addEventListener("scroll", changeCss , false);
});
