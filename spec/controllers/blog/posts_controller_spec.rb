require 'rails_helper'

describe Blog::PostsController do
  let!(:post) { create(:post) }

  describe 'index' do
    let!(:long_post) { create(:long_post, user: post.user) }

    it 'sets the @posts ivar' do
      get :index

      expect(assigns(:posts)).to include(post, long_post)
      expect(assigns(:posts).count).to be 2
    end

    it 'sets the body class' do
      get :index

      expect(assigns(:body_class)).to eql('post-template')
    end
  end

  describe 'show' do
    it 'sets the @posts ivar' do
      get :show, params: { id: post.slug }

      expect(assigns(:post)).to eql(post)
    end

    it 'sets the body class' do
      get :show, params: { id: post.slug }

      expect(assigns(:body_class)).to eql('post-template')
    end
  end
end
