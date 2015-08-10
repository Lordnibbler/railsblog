require 'rails_helper'

describe Blog::PostsController do
  fixtures :posts, :users

  let!(:post) { posts(:short) }
  let!(:long_post) { posts(:long) }

  describe 'index' do
    it 'sets the @posts ivar' do
      get :index
      expect(assigns(:posts)).to include(post, long_post)
      expect(assigns(:posts).count).to be 2
    end

    it 'sets the body class' do
      get :index
      expect(assigns(:body_class)).to eql('home-template')
    end
  end

  describe 'show' do
    it 'sets the @posts ivar' do
      get :show, id: post.slug
      expect(assigns(:post)).to eql(post)
    end

    it 'sets the body class' do
      get :show, id: post.slug
      expect(assigns(:body_class)).to eql('post-template')
    end
  end
end
