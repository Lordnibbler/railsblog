require 'features_helper'

describe '/blog' do
  include BlogHelper

  let!(:post) { create(:post_with_attached_image) }
  let!(:long_post) { create(:long_post_with_attached_image, user: post.user) }

  before { visit blog_posts_path }

  describe '#index' do
    it 'allows the document to scroll through all posts', :js do
      overflow = page.evaluate_script(<<~JS)
        [document.documentElement, document.body].map((element) =>
          getComputedStyle(element).overflowY
        )
      JS
      expect(overflow).not_to include('hidden')

      page.execute_script(<<~JS)
        const scrollTarget = document.createElement('div');
        scrollTarget.id = 'scroll-test-target';
        scrollTarget.style.height = `${window.innerHeight * 2}px`;
        document.body.appendChild(scrollTarget);
      JS

      page.execute_script('window.scrollTo(0, document.documentElement.scrollHeight)')
      expect(page).to have_css('#scroll-test-target')
      expect(page.evaluate_script('window.scrollY')).to be_positive
    end

    it 'shows title, excerpt, and featured image for posts' do
      expect(page).to have_content post.title
      expect(page).to have_content post.excerpt
      expect(page).to have_content long_post.title
      expect(page).to have_content long_post.excerpt
      expect(page).to have_css("img[src*='test.jpg']")
    end

    it 'uses the shared page surface and the appropriate post actions' do
      expect(page).to have_css('.page-surface')
      expect(page).to have_css('h1', text: 'Blog')
      expect(page).to have_css('.blog-post-card', count: 2)

      within "#post-#{post.id}" do
        expect(page).to have_link('View Post', href: blog_posts_permalink_path(post))
      end

      within "#post-#{long_post.id}" do
        expect(page).to have_link('Continue Reading', href: blog_posts_permalink_path(long_post))
      end
    end

    context 'when enough posts exist for another page' do
      before do
        4.times do |index|
          create(
            :post,
            title: "Pagination post #{index}",
            slug: "pagination-post-#{index}",
            user: post.user,
          )
        end
        visit blog_posts_path
      end

      it 'renders glass pill pagination' do
        expect(page).to have_css('nav.pagination.glass-panel[aria-label="Blog pagination"]')
        expect(page).to have_css('.pagination-pill-current[aria-current="page"]', text: '1')
        expect(page).to have_link('Next', href: blog_posts_path(page: 2))
      end
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
