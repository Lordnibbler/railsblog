require 'features_helper'

describe '/photography', :js do
  let(:photo) do
    {
      source: 'flickr',
      key: '15186163455',
      photo_thumbnail: {
        url: 'https://via.placeholder.com/100x67.jpg',
        width: 100,
        height: 67,
      },
      photo_small: {
        url: 'https://via.placeholder.com/400x267.jpg',
        width: 400,
        height: 267,
      },
      photo_medium: {
        url: 'https://via.placeholder.com/800x533.jpg',
        width: 800,
        height: 533,
      },
      photo_large: {
        url: 'https://via.placeholder.com/1600x1067.jpg',
        width: 1600,
        height: 1067,
      },
      created_at: '1410241598',
      url: 'https://via.placeholder.com/1600x1067.jpg',
      description: 'A super sweet test photo',
      title: 'IMG_6193',
    }
  end

  it 'renders the photo properly' do
    allow(FlickrService).to receive(:get_photos).and_return([photo])

    visit photography_path

    expect(page).to have_selector('figure.image.grid-item', count: 1)
    expect(page).to have_css("a[href*='#{photo[:photo_large][:url]}']")
    expect(page).to have_css("img[src*='#{photo[:photo_medium][:url]}']")
    expect(page).to have_css('figcaption', text: 'A super sweet test photo', visible: :hidden)
  end
end
