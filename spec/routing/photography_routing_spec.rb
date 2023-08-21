require 'rails_helper'

describe PhotographyController do
  it 'successfully renders the index template on GET photography_path', type: :request do
    allow(FlickrService).to receive(:get_photos_from_cache)

    get photography_path

    expect(response).to be_successful
    expect(response).to render_template(:index)
  end
end
