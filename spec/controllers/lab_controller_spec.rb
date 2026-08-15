require 'rails_helper'

describe LabController do
  describe 'index' do
    it 'provides persisted Flickr photographs to the experiments' do
      photo = instance_double(FlickrPhoto, as_stream_item: { description: 'City lights' })
      relation = double(limit: [photo])
      allow(FlickrPhoto).to receive(:order).with(:display_position).and_return(relation)

      get :index

      expect(assigns(:photos)).to eq([{ description: 'City lights' }])
      expect(assigns(:body_class)).to eq('lab-template')
    end
  end
end
