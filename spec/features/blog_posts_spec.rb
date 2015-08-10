require 'features_helper'

describe '/' do
  fixtures :users, :posts

  let!(:post) { posts(:short) }
  let!(:long_post) { posts(:long) }

  before { visit '/' }

  context 'when clicking Continue Reading' do
    it 'shows full post' do
      within "#post-#{long_post.id}" do
        click_on 'Continue Reading', exact: false
      end
      expect(page).to have_content 'Shoulder boudin pork'
      expect(page).to have_content 'Back to Overview'
      expect(page).to_not have_content 'Continue Reading'
    end
  end

  context 'when a Blog::Post is no longer published' do
    it 'removes it from the blog_posts_index_path' do
      expect(page).to have_selector('article.post', count: Blog::Post.count)
      post.update_column(:published, false)
      visit '/'
      expect(page).to have_selector('article.post', count: Blog::Post.count - 1)
      expect(page).to_not have_selector("post-#{post.id}")
    end
  end
end
