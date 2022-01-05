const setupAppHeightHandler = () => {
  // webkit "bug" means 100vh includes hidden area below navigation bar on iOS/iPadOS
  // set a css variable `--appHeight` so we can use the window's innerHeight to set the page height
  // link: https://bugs.webkit.org/show_bug.cgi?id=141832
  // code snippet: https://stackoverflow.com/a/50683190/418864
  const appHeight = () => {
    document.documentElement.style.setProperty('--app-height', `${window.innerHeight}px`);
  };

  let resizeComplete;
  window.addEventListener('resize', function () {
    this.clearTimeout(resizeComplete);
    resizeComplete = this.setTimeout(appHeight, 100);
  });
  appHeight();
}

const setupNavigationTransparencyHandler = () => {
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
    const navElement = document.querySelector(".desktop-nav");
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
    navTransparencyHandler()
  }

  // when page scrolls, update nav transparency as needed
  window.addEventListener("scroll", navTransparencyHandler, false)
}

addEventListener('turbo:load', function() {
  // resize page height according to window.innerHeight to avoid navigation bar
  // on iOS causing extra scrollable area when page has very little content
  setupAppHeightHandler()

  // make navigation transparent when scrolling past 100px
  setupNavigationTransparencyHandler()

  // flash auto-hiding
  $('.flash').on('click', function(event) {
    $(this).slideUp();
  });
})

// addEventListener("turbo:click", ({ target }) => {
//   if (target.hasAttribute("data-turbo-preserve-scroll")) {
//     scrollTop = document.scrollingElement.scrollTop
//   }
// })

addEventListener("turbo:load", () => {
    document.scrollingElement.scrollTo(0, 0)
    console.log(`turbo_load scrolling to 0`)
})

window.addEventListener('load', function() {
  document.scrollingElement.scrollTo(0, 0)
  console.log(`turbo_load scrolling to 0`)
})