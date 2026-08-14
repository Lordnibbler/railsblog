require 'features_helper'

describe '/photography', :js do
  before do
    FlickrPhoto.create!(
      flickr_id: '49822917268',
      display_position: 1,
      photo_data: {
        source: 'flickr', key: '49822917268', description: 'A test photo',
        photo_large: {
          url: 'https://live.staticflickr.com/65535/49822917268.jpg',
          width: 683,
          height: 1024,
        },
      },
    )
    FlickrPhoto.create!(
      flickr_id: '49822917269',
      display_position: 2,
      photo_data: {
        source: 'flickr', key: '49822917269', description: 'Another test photo',
        photo_large: {
          url: 'https://live.staticflickr.com/65535/49822917269.jpg',
          width: 1024,
          height: 683,
        },
      },
    )
  end

  it 'renders the photo properly' do
    visit photography_path

    # need to wait some time for the page to actually render here
    expect(page).to have_css('figure.image.grid-item', minimum: 1, wait: 30)
    # Verify that photos are rendered (we don't know the exact count from VCR)
    expect(page).to have_css('figure.image.grid-item')
    expect(page).to have_css('a[href*="flickr"]') # Flickr photo URLs
    expect(page).to have_css('img[src*="flickr"]') # Flickr image sources
    expect(page).to have_css('.infinite-scroll-spinner', visible: :hidden)
    expect(page).to have_css('.glass-footer')
  end

  it 'uses light navigation content over the photo gallery' do
    page.current_window.resize_to(1400, 700)
    visit photography_path

    expect(page).to have_css('.my-gallery[data-navigation-contrast="light"]', wait: 30)
    page.execute_script('window.scrollTo(0, 200)')

    expect(page).to have_css('.desktop-nav.nav-liquid-glass.nav-glass-on-dark')
  end

  it 'opens PhotoSwipe when a photo is clicked' do
    visit photography_path

    expect(page).to have_css('figure.image.grid-item a', minimum: 1, wait: 30)
    photo_link = first('figure.image.grid-item a')
    caption = photo_link.find(:xpath, '../figcaption', visible: :all).text(:all)
    photo_link.click

    expect(page).to have_css('.pswp.pswp--open', wait: 10)
    expect(page).to have_css('.pswp__button--close')
    expect(page).to have_css('.pswp__button--fs')
    expect(page).to have_css('.pswp__counter')

    expect(page).to have_css('.pswp__button--arrow--next')
    expect(page).to have_css('.pswp__counter', text: %r{\d+\s*/\s*\d+})
    expect(page).to have_css('.pswp__custom-caption', text: caption)
    expect(page).to have_css('.pswp__custom-caption')

    expect(page).to have_css('.pswp.pswp--idle', visible: :all, wait: 5)
    expect(page).to have_css('.pswp.pswp--idle .pswp__top-bar', visible: :hidden, wait: 1)
  end
end
