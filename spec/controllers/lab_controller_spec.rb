require 'rails_helper'

describe LabController do
  describe 'index' do
    it 'provides persisted Flickr photographs to the experiments' do
      photo = instance_double(
        FlickrPhoto,
        flickr_id: '123',
        as_stream_item: { description: 'City lights' },
        composition_analyzed?: true,
        composition_analysis: { 'summary' => 'Layered city scene' },
      )
      relation = double(limit: [photo])
      allow(FlickrPhoto).to receive(:order).with(Arel.sql('RANDOM()')).and_return(relation)

      get :index

      expected_photos = [{
        description: 'City lights', flickr_id: '123',
        composition_analysis: { 'summary' => 'Layered city scene' },
      }]
      expect(assigns(:photos)).to eq(expected_photos)
      expect(assigns(:body_class)).to eq('lab-template')
    end
  end
end
