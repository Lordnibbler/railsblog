import PhotoSwipe from 'photoswipe';
import PhotoSwipeLightbox from 'photoswipe/lightbox';
import InfiniteScroll from 'infinite-scroll';
import Masonry from 'masonry-layout';
import imagesLoaded from 'imagesloaded';

// build and return a new Masonry object
const createMasonry = (elem) => {
    return new Masonry( elem, {
        // use outer width of grid-sizer for columnWidth
        // do not use .grid-sizer in layout!
        columnWidth: '.grid-sizer',
        itemSelector: '.grid-item',

        // responsive
        percentPosition: true,

        // nicer reveal transition
        visibleStyle: { transform: 'translateY(0)', opacity: 1 },
        hiddenStyle: { transform: 'translateY(100px)', opacity: 0 },
    });
}

// build and return a new InfiniteScroll object
const createInfiniteScroll = (elem, masonry) => {
    return new InfiniteScroll( elem, {
        // options
        path: '.pagination-next',
        append: 'figure.image.grid-item',
        status: '.page-load-status',
        history: false,
        outlayer: masonry,
    });
}

const parsePhotoSwipeHash = () => {
    const params = new URLSearchParams(window.location.hash.substring(1));
    return {
        galleryIndex: Number.parseInt(params.get('gid'), 10) - 1,
        photoIndex: Number.parseInt(params.get('pid'), 10) - 1,
    };
};

// Build the PhotoSwipe v5 lightbox and restore the caption and navigation behavior.
const initPhotoSwipeFromDOM = (gallerySelector) => {
    const galleryElements = document.querySelectorAll(gallerySelector);
    if (!galleryElements.length) return;
    let idleTimer;
    let activePhotoSwipeElement;
    let lastPointerPosition;

    const resetIdleTimer = () => {
        activePhotoSwipeElement?.classList.remove('pswp--idle');
        window.clearTimeout(idleTimer);
        idleTimer = window.setTimeout(() => {
            activePhotoSwipeElement?.classList.add('pswp--idle');
        }, 2500);
    };

    const handlePointerMove = ({ clientX, clientY }) => {
        if (lastPointerPosition?.x === clientX && lastPointerPosition?.y === clientY) return;

        lastPointerPosition = { x: clientX, y: clientY };
        resetIdleTimer();
    };

    const lightbox = new PhotoSwipeLightbox({
        gallery: galleryElements,
        children: 'figure.image a',
        bgOpacity: 1,
        pswpModule: PhotoSwipe,
    });

    lightbox.on('uiRegister', () => {
        const { pswp } = lightbox;

        lightbox.pswp.ui.registerElement({
            name: 'custom-caption',
            order: 9,
            isButton: false,
            appendTo: 'root',
            onInit: (captionElement, pswp) => {
                pswp.on('change', () => {
                    const figure = pswp.currSlide.data.element?.closest('figure');
                    captionElement.innerHTML = figure?.querySelector('figcaption')?.innerHTML || '';
                });
            },
        });

        const requestFullscreen = pswp.element.requestFullscreen || pswp.element.webkitRequestFullscreen;
        if (requestFullscreen) {
            pswp.ui.registerElement({
                name: 'fs',
                ariaLabel: 'Toggle fullscreen',
                order: 16,
                isButton: true,
                html: 'Fullscreen',
                onClick: () => {
                    const fullscreenElement = document.fullscreenElement || document.webkitFullscreenElement;
                    if (fullscreenElement) {
                        (document.exitFullscreen || document.webkitExitFullscreen).call(document);
                    } else {
                        requestFullscreen.call(pswp.element);
                    }
                },
            });
        }
    });

    lightbox.on('openingAnimationStart', () => {
        const navElement = document.querySelector('.desktop-nav');
        navElement?.classList.add('animate-hideTop');
        navElement?.classList.remove('animate-showTop');
    });
    lightbox.on('afterInit', () => {
        activePhotoSwipeElement = lightbox.pswp.element;
        activePhotoSwipeElement.addEventListener('pointermove', handlePointerMove);
        activePhotoSwipeElement.addEventListener('pointerdown', resetIdleTimer);
        activePhotoSwipeElement.addEventListener('keydown', resetIdleTimer);
        resetIdleTimer();
    });
    lightbox.on('close', () => {
        const navElement = document.querySelector('.desktop-nav');
        navElement?.classList.remove('animate-hideTop');
        navElement?.classList.add('animate-showTop');

        window.clearTimeout(idleTimer);
        activePhotoSwipeElement?.removeEventListener('pointermove', handlePointerMove);
        activePhotoSwipeElement?.removeEventListener('pointerdown', resetIdleTimer);
        activePhotoSwipeElement?.removeEventListener('keydown', resetIdleTimer);
        activePhotoSwipeElement = undefined;
        lastPointerPosition = undefined;
    });

    lightbox.init();

    // Preserve v4 deep links such as #&pid=3&gid=1 without enabling history changes.
    const { galleryIndex, photoIndex } = parsePhotoSwipeHash();
    if (galleryIndex >= 0 && photoIndex >= 0 && galleryElements[galleryIndex]) {
        lightbox.options.showAnimationDuration = 0;
        lightbox.loadAndOpen(photoIndex, { gallery: galleryElements[galleryIndex] });
    }

    return lightbox;
};

// logic to fire on (turbolinks) page load
$(document).on('turbo:load', function() {
    const elem = document.querySelector('.my-gallery.grid');
    if (elem) {
        let msnry = createMasonry(elem)

        // Unloaded images can throw off Masonry layouts and cause item elements to overlap.
        // imagesLoaded resolves this issue.
        // note: this seems to work and only is important for first page load
        imagesLoaded( elem, () => {
            elem.classList.remove('are-images-unloaded');
            msnry.options.itemSelector = 'figure.image.grid-item';
            msnry.layout()
        });

        // make imagesLoaded available for InfiniteScroll
        InfiniteScroll.imagesLoaded = imagesLoaded;

        // instantiate infinite scroll with the gallery and masonry
        createInfiniteScroll(elem, msnry);

        // 250ms after a resize finishes, re-run masonry.layout(),
        // and rebuild a new infinite scroll with the new masonry layout
        let resizeComplete;
        window.addEventListener('resize', function () {
            this.clearTimeout(resizeComplete);
            resizeComplete = this.setTimeout(() => {
                msnry.layout();
                createInfiniteScroll(elem, msnry);
            }, 250);
        });

        // start up Photoswipe
        initPhotoSwipeFromDOM('.my-gallery');
    }
});
