import 'photoswipe/dist/photoswipe.css'
import 'photoswipe/dist/default-skin/default-skin.css'
import PhotoSwipe from 'photoswipe';
import PhotoSwipeUI_Default from 'photoswipe/dist/photoswipe-ui-default';
import InfiniteScroll from 'infinite-scroll';
import Masonry from 'masonry-layout';
import imagesLoaded from 'imagesloaded';
import './photography.sass';

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
        checkLastPage: 'figure.image.grid-item',
        path: 'photography?page={{#}}',
        append: 'figure.image.grid-item',
        history: false,
        outlayer: masonry,
        status: '.page-load-status',
    });
}

// build the Photoswipe gallery from the provided CSS selector
const initPhotoSwipeFromDOM = function(gallerySelector) {

    // parse slide data (url, title, size ...) from DOM elements
    // (children of gallerySelector)
    var parseThumbnailElements = function(el) {
        var thumbElements = el.childNodes,
            numNodes = thumbElements.length,
            items = [],
            figureEl,
            linkEl,
            size,
            item;

        for(var i = 1; i < numNodes; i++) {

            figureEl = thumbElements[i]; // <figure> element

            // include only element nodes
            if(figureEl.nodeType !== 1) {
                continue;
            }

            linkEl = figureEl.children[0]; // <a> element
            size = linkEl.getAttribute('data-size').split('x');

            // create slide object
            item = {
                src: linkEl.getAttribute('href'),
                w: parseInt(size[0], 10),
                h: parseInt(size[1], 10)
            };



            if(figureEl.children.length > 1) {
                // <figcaption> content
                item.title = figureEl.children[1].innerHTML;
            }

            if(linkEl.children.length > 0) {
                // <img> thumbnail element, retrieving thumbnail url
                item.msrc = linkEl.children[0].getAttribute('src');
            }

            item.el = figureEl; // save link to element for getThumbBoundsFn
            items.push(item);
        }

        return items;
    };

    // find nearest parent element
    var closest = function closest(el, fn) {
        return el && ( fn(el) ? el : closest(el.parentNode, fn) );
    };

    // triggers when user clicks on thumbnail
    var onThumbnailsClick = function(e) {
        e = e || window.event;
        e.preventDefault ? e.preventDefault() : e.returnValue = false;

        var eTarget = e.target || e.srcElement;

        // find root element of slide
        var clickedListItem = closest(eTarget, function(el) {
            return (el.tagName && el.tagName.toUpperCase() === 'FIGURE');
        });

        if(!clickedListItem) {
            return;
        }

        // find index of clicked item by looping through all child nodes
        // alternatively, you may define index via data- attribute
        var clickedGallery = clickedListItem.parentNode,
            childNodes = clickedListItem.parentNode.childNodes,
            numChildNodes = childNodes.length,
            nodeIndex = 0,
            index;

        for (var i = 1; i < numChildNodes; i++) {
            if(childNodes[i].nodeType !== 1) {
                continue;
            }

            if(childNodes[i] === clickedListItem) {
                index = nodeIndex;
                break;
            }
            nodeIndex++;
        }



        if(index >= 0) {
            // open PhotoSwipe if valid index found
            openPhotoSwipe( index, clickedGallery );
        }
        return false;
    };

    // parse picture index and gallery index from URL (#&pid=1&gid=2)
    var photoswipeParseHash = function() {
        var hash = window.location.hash.substring(1),
            params = {};

        if(hash.length < 5) {
            return params;
        }

        var vars = hash.split('&');
        for (var i = 0; i < vars.length; i++) {
            if(!vars[i]) {
                continue;
            }
            var pair = vars[i].split('=');
            if(pair.length < 2) {
                continue;
            }
            params[pair[0]] = pair[1];
        }

        if(params.gid) {
            params.gid = parseInt(params.gid, 10);
        }

        return params;
    };

    var openPhotoSwipe = function(index, galleryElement, disableAnimation, fromURL) {
        var pswpElement = document.querySelectorAll('.pswp')[0],
            gallery,
            options,
            items;

        items = parseThumbnailElements(galleryElement);

        // define options (if needed)
        options = {

            // define gallery index (for URL)
            galleryUID: galleryElement.getAttribute('data-pswp-uid'),

            getThumbBoundsFn: function(index) {
                // See Options -> getThumbBoundsFn section of documentation for more info
                var thumbnail = items[index].el.getElementsByTagName('img')[0], // find thumbnail
                    pageYScroll = window.pageYOffset || document.documentElement.scrollTop,
                    rect = thumbnail.getBoundingClientRect();

                return {x:rect.left, y:rect.top + pageYScroll, w:rect.width};
            }

        };

        // PhotoSwipe opened from URL
        if(fromURL) {
            if(options.galleryPIDs) {
                // parse real index when custom PIDs are used
                // http://photoswipe.com/documentation/faq.html#custom-pid-in-url
                for(var j = 0; j < items.length; j++) {
                    if(items[j].pid == index) {
                        options.index = j;
                        break;
                    }
                }
            } else {
                // in URL indexes start from 1
                options.index = parseInt(index, 10) - 1;
            }
        } else {
            options.index = parseInt(index, 10);
        }

        // exit if index not found
        if( isNaN(options.index) ) {
            return;
        }

        if(disableAnimation) {
            options.showAnimationDuration = 0;
        }

        // backing out of the photoswipe full screen causes page reload (turbolinks)
        // disable back button support until this is fixed:
        // https://github.com/dimsemenov/PhotoSwipe/issues/700
        options.history = false;

        // Pass data to PhotoSwipe and initialize it
        gallery = new PhotoSwipe(pswpElement, PhotoSwipeUI_Default, items, options);
        gallery.init();

        // event handlers to animate the navigation div on open/close of photoswipe gallery
        gallery.listen('initialZoomIn', function() {
            let navElement = document.querySelector(".desktop-nav");
            navElement.classList.add("animate-hideTop")
            navElement.classList.remove("animate-showTop")
        });
        gallery.listen('close', function() {
            let navElement = document.querySelector(".desktop-nav");
            navElement.classList.remove("animate-hideTop")
            navElement.classList.add("animate-showTop")
        });
    };

    // loop through all gallery elements and bind events
    var galleryElements = document.querySelectorAll( gallerySelector );

    for(var i = 0, l = galleryElements.length; i < l; i++) {
        galleryElements[i].setAttribute('data-pswp-uid', i+1);
        galleryElements[i].onclick = onThumbnailsClick;
    }

    // Parse URL and open gallery if it contains #&pid=3&gid=1
    var hashData = photoswipeParseHash();
    if(hashData.pid && hashData.gid) {
        openPhotoSwipe( hashData.pid ,  galleryElements[ hashData.gid - 1 ], true, true );
    }
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
        let infiniteScroll = createInfiniteScroll(elem, msnry);

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
