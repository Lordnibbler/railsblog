require 'features_helper'

describe '/admin' do
  fixtures :users
  let(:user) { users(:ben) }

  describe '/login' do
    context 'with valid credentials' do
      it 'redirects to dashboard' do
        visit '/admin'
        within '#session_new' do
          fill_in 'user_email',    with: user.email
          fill_in 'user_password', with: 'password'
        end
        click_button 'Login'
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
        expect(page).to have_content 'Invalid email or password'
      end
    end
  end

  describe '/blog_posts' do
    before { login_as(user, scope: :user) }

    describe '/new' do
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
  end
end
