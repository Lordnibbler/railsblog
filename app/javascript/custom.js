import $ from 'jquery';

let pageLifecycleController;

const setupAppHeightHandler = (signal) => {
  // webkit "bug" means 100vh includes hidden area below navigation bar on iOS/iPadOS
  // set a css variable `--appHeight` so we can use the window's innerHeight to set the page height
  // link: https://bugs.webkit.org/show_bug.cgi?id=141832
  // code snippet: https://stackoverflow.com/a/50683190/418864
  const appHeight = () => {
    document.documentElement.style.setProperty('--app-height', `${window.innerHeight}px`);
  };

  let resizeComplete;
  window.addEventListener('resize', () => {
    window.clearTimeout(resizeComplete);
    resizeComplete = window.setTimeout(appHeight, 100);
  }, { signal });
  appHeight();
}

const setupNavigationTransparencyHandler = (signal) => {
  const navElement = document.querySelector(".desktop-nav");
  if (!navElement) return;

  const colorScheme = window.matchMedia("(prefers-color-scheme: dark)");

  function updateNavigationContrast() {
    const sampleY = Math.max(0, Math.min(window.innerHeight - 1, navElement.getBoundingClientRect().bottom - 1));
    const underlyingElement = document.elementsFromPoint(window.innerWidth / 2, sampleY)
      .find((element) => !navElement.contains(element));
    const requestedContrast = underlyingElement?.closest("[data-navigation-contrast]")
      ?.dataset.navigationContrast
      || (underlyingElement?.closest("video, iframe") ? "light" : undefined)
      || (document.body.classList.contains("photography-template") ? "light" : undefined);
    const contrast = requestedContrast || (colorScheme.matches ? "light" : "dark");

    navElement.classList.toggle("nav-glass-on-dark", contrast === "light");
    navElement.classList.toggle("nav-glass-on-light", contrast === "dark");
  }

  function navTransparencyHandler() {
    //
    // when page is scrolled down >=100px, give the navigation a liquid-glass surface
    // when page is scrolled up <100px, make the navigation 100% transparent (home) or opaque (all other pages)
    //
    let notScrolledClasses // class when page is scrolled to top
    let scrolledClasses = ["nav-liquid-glass"] // class when page is scrolled past 100px
    if (window.location.pathname === "/") {
      notScrolledClasses = ["bg-primary/0", "dark:bg-primary-50/0"]
    } else {
      notScrolledClasses = ["bg-primary", "dark:bg-primary-50"]
    }

    // event listener logic, when page scrolls past 100px y-axis, switch CSS background
    if (window.scrollY > 100) {
      navElement.classList.add(...scrolledClasses)
      navElement.classList.remove(...notScrolledClasses)
      updateNavigationContrast()
    } else {
      navElement.classList.add(...notScrolledClasses)
      navElement.classList.remove(...scrolledClasses)
      navElement.classList.remove("nav-glass-on-dark", "nav-glass-on-light")
    }
  }

  // run once on homepage load to ensure classes are set appropriately,
  // in case of linking straight to homepage on an anchor (hash)
  if (window.location.pathname === "/" && window.location.hash) {
    navTransparencyHandler()
  }

  // when page scrolls, update nav transparency as needed
  window.addEventListener("scroll", navTransparencyHandler, { signal })

  // Theme changes can alter the background beneath a stationary header.
  const colorSchemeHandler = () => {
    if (navElement.classList.contains("nav-liquid-glass")) {
      updateNavigationContrast()
    }
  }
  colorScheme.addEventListener("change", colorSchemeHandler, { signal })
}

const setupLazyVideos = (signal) => {
  const videos = document.querySelectorAll('video.lazy-video');
  if (!videos.length) return;

  const loadVideo = (video) => {
    video.querySelectorAll('source[data-src]').forEach((source) => {
      source.src = source.dataset.src;
      source.removeAttribute('data-src');
    });
    video.load();
    video.play().catch(() => {});
  };

  if (!('IntersectionObserver' in window)) {
    videos.forEach(loadVideo);
    return;
  }

  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (!entry.isIntersecting) return;

      loadVideo(entry.target);
      observer.unobserve(entry.target);
    });
  }, { rootMargin: '300px' });

  signal.addEventListener('abort', () => observer.disconnect(), { once: true });
  videos.forEach((video) => observer.observe(video));
}

addEventListener('turbo:load', function() {
  pageLifecycleController?.abort();
  pageLifecycleController = new AbortController();
  const { signal } = pageLifecycleController;

  // resize page height according to window.innerHeight to avoid navigation bar
  // on iOS causing extra scrollable area when page has very little content
  setupAppHeightHandler(signal)

  // make navigation transparent when scrolling past 100px
  setupNavigationTransparencyHandler(signal)

  // Avoid downloading large, below-the-fold videos until they are nearly visible.
  setupLazyVideos(signal)

  // flash auto-hiding
  $('.flash').off('click.radler').on('click.radler', function() {
    const $flash = $(this);
    $flash.slideUp(150, function() {
      const $container = $flash.closest('.flash-container');
      $flash.remove();
      if ($container.find('.flash:visible').length === 0) {
        $container.remove();
      }
    });
  });
})
