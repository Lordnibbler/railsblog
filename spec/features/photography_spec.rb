require 'features_helper'

describe '/photography', :js do
  # VCR will record API calls on first run and replay them on subsequent runs
  # This prevents real API calls and timeouts in tests
  # The cassette will be saved to: spec/vcr_cassettes/photography/renders_the_photo_properly.yml
  it 'renders the photo properly', :vcr do
    visit photography_path

    # need to wait some time for the page to actually render here
    expect(page).to have_css('figure.image.grid-item', minimum: 1, wait: 30)
    # Verify that photos are rendered (we don't know the exact count from VCR)
    expect(page).to have_css('figure.image.grid-item')
    expect(page).to have_css('a[href*="flickr"]') # Flickr photo URLs
    expect(page).to have_css('img[src*="flickr"]') # Flickr image sources
  end

  it 'opens PhotoSwipe when a photo is clicked', :vcr do
    visit photography_path

    expect(page).to have_css('figure.image.grid-item a', minimum: 1, wait: 30)
    first('figure.image.grid-item a').click

    expect(page).to have_css('.pswp.pswp--open', wait: 10)
  end
end
