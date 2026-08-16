require 'rails_helper'

RSpec.describe PhotoSubjectClassifier do
  it 'assigns multiple relevant subjects from stored vision analysis' do
    photo = Struct.new(:photo_data, :composition_analysis, keyword_init: true).new(
      photo_data: { 'title' => 'Market crossing' },
      composition_analysis: {
        'summary' => 'A pedestrian crosses a city street beside a bus and an architectural facade.',
        'techniques' => [],
      },
    )

    expect(described_class.call(photo)).to contain_exactly(:people, :street, :architecture, :transit)
  end

  it 'keeps unrelated subjects out of a landscape photograph' do
    photo = Struct.new(:photo_data, :composition_analysis, keyword_init: true).new(
      photo_data: { 'description' => 'Clouds above an ocean horizon and wooded hills.' },
      composition_analysis: {},
    )

    expect(described_class.call(photo)).to eq([:landscape])
  end

  it 'classifies from Flickr metadata when vision analysis is unavailable' do
    photo = FlickrPhoto.new(photo_data: { 'title' => 'Dog on a city sidewalk' })

    expect(described_class.call(photo)).to contain_exactly(:animals, :street)
  end
end
