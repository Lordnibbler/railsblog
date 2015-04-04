require 'rails_helper'

describe Blog::PostsController do
  context 'when GET is to a legacy routes without /blog', type: :request do
    it 'redirects to /blog/<params>' do
      get '/2015/01/31/post-title'
      expect(response).to redirect_to('/blog/2015/01/31/post-title')
    end
  end
end
