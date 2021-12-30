require 'features_helper'

describe '/admin' do
  let(:user) { create(:user) }

  describe '/login' do
    context 'with valid credentials' do
      it 'redirects to dashboard' do
        visit '/admin'
        within '#session_new' do
          fill_in 'user_email',    with: user.email
          fill_in 'user_password', with: 'password'
        end
        click_button 'Login'

        expect(page).to have_current_path(admin_root_path)
        expect(page).to have_content 'Dashboard'
      end
    end

    context 'with invalid credentials' do
      it 'shows error' do
        visit '/admin'
        within '#session_new' do
          fill_in 'user_email',    with: user.email
          fill_in 'user_password', with: 'invalid'
        end
        click_button 'Login'

        expect(page).to have_content 'Invalid Email or password'
      end
    end
  end

  describe 'blog_posts' do
    before { login_as(user, scope: :user) }

    describe '/admin/blog_posts/new' do
      it 'creates a new blog post' do
        visit '/admin/blog_posts'
        click_on 'New Blog Post'
        expect(page).to have_content 'New Blog Post'
        expect do
          within '#new_blog_post' do
            fill_in 'blog_post_title', with: 'New Post'
            fill_in 'blog_post_body',  with: 'Some body'
            select user.name, from: 'blog_post_user_id'
            click_on 'Create Post'
          end
        end.to change { Blog::Post.count }.by(1)

        expect(page).to have_content 'Post was successfully created'
        expect(page).to have_content 'New Post'
        expect(page).to have_content 'Some body'
        expect(page).to have_content user.name
      end
    end

    context 'featured image' do
      let!(:post) { create(:post, user: user) }

      it 'shows and allows uploading and deleting of featured_image' do
        visit '/admin/blog_posts'
        within "#blog_post_#{post.id}" do
          click_on 'View'
          expect(page).to have_current_path(admin_blog_post_path(post))
        end

        within '.row-featured_image' do
          expect(page).to have_selector("img[src*='test.jpg']")
          expect(page).to have_selector('a.default-button', text: 'Original')
          expect(page).to have_selector('a.danger-button', text: 'Delete')
          click_on 'Delete'
        end

        page.accept_alert

        within '.row-featured_image' do
          expect(page).to_not have_selector("img[src*='test.jpg']")
          expect(page).to_not have_selector('a.default-button', text: 'Original')
          expect(page).to_not have_selector('a.danger-button', text: 'Delete')
        end

        visit edit_admin_blog_post_path(post)

        within '#blog_post_featured_image_input' do
          attach_file('Featured image', Rails.root.join('spec/factories/fixture_files/test.jpg'))
        end

        within '#blog_post_submit_action' do
          click_on('Update Post')
        end

        expect(page).to have_current_path(admin_blog_post_path(post))

        within '.row-featured_image' do
          expect(page).to have_selector("img[src*='test.jpg']")
          expect(page).to have_selector('a.default-button', text: 'Original')
          expect(page).to have_selector('a.danger-button', text: 'Delete')
        end
      end
    end

    context 'images' do
      let!(:post) { create(:post, user: user) }

      it 'allows uploading and deleting of images' do
        visit edit_admin_blog_post_path(post)

        within '#blog_post_images_input' do
          attach_file('Images', Rails.root.join('spec/factories/fixture_files/test.jpg'))
        end

        within '#blog_post_submit_action' do
          click_on('Update Post')
        end

        expect(page).to have_current_path(admin_blog_post_path(post))

        within '.row-images' do
          expect(page).to have_selector("img[src*='test.jpg']")
          expect(page).to have_selector('a.default-button', text: 'Original')
          expect(page).to have_selector('a.default-button', text: '300')
          expect(page).to have_selector('a.default-button', text: '640')
          expect(page).to have_selector('a.default-button', text: '1024')
          expect(page).to have_selector('a.danger-button', text: 'Delete')
          click_on 'Delete'
        end

        page.accept_alert

        within '.row-images' do
          expect(page).to_not have_selector("img[src*='test.jpg']")
          expect(page).to_not have_selector('a.default-button', text: 'Original')
          expect(page).to_not have_selector('a.default-button', text: '300')
          expect(page).to_not have_selector('a.default-button', text: '640')
          expect(page).to_not have_selector('a.default-button', text: '1024')
          expect(page).to_not have_selector('a.danger-button', text: 'Delete')
        end
      end
    end
  end
end
