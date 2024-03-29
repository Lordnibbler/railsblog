require 'rails_helper'

describe HomeController do
  let!(:post) { create(:post) }
  let!(:long_post) { create(:long_post, user: post.user) }
  let!(:unpublished_post) { create(:unpublished_post, user: post.user) }

  describe 'get #index' do
    subject(:get_index) { get 'index' }

    before { get_index }

    it 'fetches published blog posts' do
      expect(assigns(:posts).count).to be(2)
      expect(assigns(:posts)).to include(post)
      expect(assigns(:posts)).to include(long_post)
    end
  end
end
