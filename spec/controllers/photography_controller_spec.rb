require 'rails_helper'

describe PhotographyController do
  let(:photo) do
    { source: 'flickr', key: '14224430131' }
  end

  describe 'index' do
    it 'fetches photos for the passed page param' do
      allow(FlickrService).to receive(:get_photos).and_return([photo])

      get :index, params: { page: 1 }

      expect(assigns(:photos)).to eq([photo])
    end

    it 'returns empty list when get_photos returns nil' do
      allow(FlickrService).to receive(:get_photos).and_return(nil)

      get :index, params: { page: 100 }

      expect(assigns(:photos)).to eq([])
    end

    it 'sets body class' do
      allow(FlickrService).to receive(:get_photos).and_return(nil)

      get :index, params: { page: 1 }

      expect(assigns(:body_class)).to eq('overflow-x-hidden photography-template')
    end
  end
end
