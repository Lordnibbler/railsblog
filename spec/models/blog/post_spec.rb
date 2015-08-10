require 'rails_helper'

RSpec.describe Blog::Post, type: :model do
  fixtures :users, :posts

  let(:post)      { posts(:short) }
  let(:long_post) { posts(:long) }

  describe 'author' do
    let(:user) { users(:ben) }

    context 'when no name' do
      before { user.update_attribute(:name, '') }
      it 'returns a thing' do
        expect(post.author).to eql('')
      end
    end

    context 'when name' do
      it 'returns a human-readable name' do
        expect(post.author).to eql('Ben Radler')
      end
    end
  end

  describe 'excerpt' do
    context 'when no EXCERPT_TAG' do
      it 'returns all of the body' do
        expect(post.excerpt).to eql(post.body)
      end
    end

    context 'when EXCERPT_TAG' do
      it 'returns only the body content before the EXCERPT_TAG' do
        expect(long_post.excerpt).to_not eql(long_post.body)
        expect(long_post.excerpt).to_not include('<!--more-->')
      end
    end
  end

  describe 'more_text?' do
    context 'when no EXCERPT_TAG' do
      it 'returns false' do
        expect(post.more_text?).to be false
      end
    end

    context 'when EXCERPT_TAG' do
      it 'returns true' do
        expect(long_post.more_text?).to be true
      end
    end
  end
end
