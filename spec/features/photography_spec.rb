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
  end

  it 'opens PhotoSwipe when a photo is clicked' do
    visit photography_path

    expect(page).to have_css('figure.image.grid-item a', minimum: 1, wait: 30)
    first('figure.image.grid-item a').click

    expect(page).to have_css('.pswp.pswp--open', wait: 10)
    expect(page).to have_css('.pswp__button--close')
    expect(page).to have_css('.pswp__counter')

    expect(page).to have_css('.pswp__button--arrow--right')
    expect(page).to have_css('.pswp__counter', text: %r{\d+\s*/\s*\d+})
  end
end
