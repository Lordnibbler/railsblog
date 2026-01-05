require 'features_helper'

describe '/blog' do
  include BlogHelper

  let!(:post) { create(:post_with_attached_image) }
  let!(:long_post) { create(:long_post_with_attached_image, user: post.user) }

  before { visit blog_posts_path }

  describe '#index' do
    it 'shows title, excerpt, and featured image for posts' do
      expect(page).to have_content post.title
      expect(page).to have_content post.excerpt
      expect(page).to have_content long_post.title
      expect(page).to have_content long_post.excerpt
      expect(page).to have_css("img[src*='test.jpg']")
    end

    context 'when a Blog::Post is no longer published' do
      it 'removes it from the blog_posts_index_path' do
        original_published_count = Blog::Post.published.count
        expect(page).to have_css('[role="article"]', count: original_published_count)

        post.update_column(:published, false)

        visit blog_posts_path

        expect(page).to have_css('[role="article"]', count: original_published_count - 1)
        expect(page).to have_no_css("post-#{post.id}")
      end
    end
  end

  context 'when clicking Continue Reading' do
    it 'shows full post with featured image' do
      within "#post-#{long_post.id}" do
        expect(page).to have_link('Continue Reading', href: blog_posts_permalink_path(long_post))
        click_on 'Continue Reading', exact: false
      end

      expect(page).to have_current_path(blog_posts_permalink_path(long_post))
      expect(page).to have_content 'Spicy jalapeno bacon'
      expect(page).to have_content(/Previous Post/i)
      expect(page).to have_no_content 'Continue Reading'
      expect(page).to have_css("img[src*='test.jpg']")
    end
  end
end
