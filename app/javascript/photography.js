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

const rgbToMood = (red, green, blue) => {
    const maximum = Math.max(red, green, blue) / 255;
    const minimum = Math.min(red, green, blue) / 255;
    const saturation = maximum === minimum ? 0 : (maximum - minimum) / (1 - Math.abs(maximum + minimum - 1));
    let hue = 0;
    if (maximum !== minimum) {
        if (maximum === red / 255) hue = 60 * (((green - blue) / 255) / (maximum - minimum));
        else if (maximum === green / 255) hue = 60 * (((blue - red) / 255) / (maximum - minimum) + 2);
        else hue = 60 * (((red - green) / 255) / (maximum - minimum) + 4);
    }
    if (hue < 0) hue += 360;
    if (saturation < 0.2) return 'quiet';
    return hue < 78 || hue > 318 ? 'warm' : 'cool';
};

const fallbackColor = (source) => {
    const hash = [...source].reduce((value, character) => ((value * 31) + character.charCodeAt(0)) >>> 0, 2166136261);
    return [72 + hash % 150, 68 + (hash >> 8) % 140, 82 + (hash >> 16) % 150];
};

const sampleImageColor = (source) => new Promise((resolve) => {
    const image = new Image();
    image.crossOrigin = 'anonymous';
    image.onload = () => {
        try {
            const canvas = document.createElement('canvas');
            canvas.width = 12; canvas.height = 12;
            const context = canvas.getContext('2d', { willReadFrequently: true });
            context.drawImage(image, 0, 0, 12, 12);
            const pixels = context.getImageData(0, 0, 12, 12).data;
            let red = 0; let green = 0; let blue = 0; let count = 0;
            for (let index = 0; index < pixels.length; index += 16) {
                if (pixels[index + 3] < 128) continue;
                red += pixels[index]; green += pixels[index + 1]; blue += pixels[index + 2]; count += 1;
            }
            resolve(count ? [red / count, green / count, blue / count] : fallbackColor(source));
        } catch (_error) { resolve(fallbackColor(source)); }
    };
    image.onerror = () => resolve(fallbackColor(source));
    image.src = source;
});

const decorateGalleryItems = (gallery, items, applyFilter) => {
    const allItems = [...gallery.querySelectorAll('[data-gallery-item]')];
    items.forEach((item) => {
        const position = allItems.indexOf(item) + 1;
        item.dataset.galleryIndex = position;
        const number = item.querySelector('.photography-card-number');
        if (number) number.textContent = String(position).padStart(2, '0');
        if (item.dataset.colorReady) return;
        item.dataset.colorReady = 'true';
        const source = item.querySelector('img')?.currentSrc || item.querySelector('img')?.src;
        if (!source) return;
        sampleImageColor(source).then(([red, green, blue]) => {
            item.style.setProperty('--photo-accent', `${Math.round(red)} ${Math.round(green)} ${Math.round(blue)}`);
            item.dataset.galleryMood = rgbToMood(red, green, blue);
            applyFilter();
        });
    });
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
        let activeMood = 'all';
        const visibleStatus = document.querySelector('[data-gallery-visible]');
        const applyFilter = () => {
            elem.querySelectorAll('[data-gallery-item]').forEach((item) => {
                item.classList.toggle('is-filtered', activeMood !== 'all' && item.dataset.galleryMood !== activeMood);
            });
            const visibleCount = elem.querySelectorAll('[data-gallery-item]:not(.is-filtered)').length;
            if (visibleStatus) visibleStatus.textContent = visibleCount;
            msnry.layout();
        };

        document.querySelectorAll('[data-gallery-density]').forEach((button) => {
            button.addEventListener('click', () => {
                const mosaic = button.dataset.galleryDensity === 'mosaic';
                elem.classList.toggle('gallery-mosaic', mosaic);
                elem.classList.toggle('gallery-editorial', !mosaic);
                document.querySelectorAll('[data-gallery-density]').forEach((option) => {
                    const selected = option === button;
                    option.classList.toggle('is-active', selected);
                    option.setAttribute('aria-pressed', selected.toString());
                });
                msnry.layout();
            });
        });

        document.querySelectorAll('[data-gallery-mood]').forEach((button) => {
            button.addEventListener('click', () => {
                activeMood = button.dataset.galleryMood;
                document.querySelectorAll('[data-gallery-mood]').forEach((option) => {
                    const selected = option === button;
                    option.classList.toggle('is-active', selected);
                    option.setAttribute('aria-pressed', selected.toString());
                });
                applyFilter();
            });
        });

        // Unloaded images can throw off Masonry layouts and cause item elements to overlap.
        // imagesLoaded resolves this issue.
        // note: this seems to work and only is important for first page load
        imagesLoaded( elem, () => {
            elem.classList.remove('are-images-unloaded');
            msnry.options.itemSelector = 'figure.image.grid-item';
            msnry.layout()
            decorateGalleryItems(elem, [...elem.querySelectorAll('[data-gallery-item]')], applyFilter);
        });

        // make imagesLoaded available for InfiniteScroll
        InfiniteScroll.imagesLoaded = imagesLoaded;

        // instantiate infinite scroll with the gallery and masonry
        const infiniteScroll = createInfiniteScroll(elem, msnry);
        infiniteScroll.on('append', (_body, _path, newItems) => {
            decorateGalleryItems(elem, [...newItems], applyFilter);
            msnry.layout();
        });

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
