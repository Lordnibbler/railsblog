require 'rails_helper'

RSpec.describe Blog::Post do
  let(:post) { create(:post) }

  describe 'author' do
    context 'when no name' do
      before { post.user.name = '' }

      it 'returns empty string' do
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
      let(:long_post) { create(:long_post) }

      it 'returns only the body content before the EXCERPT_TAG' do
        expect(long_post.excerpt).not_to eql(long_post.body)
        expect(long_post.excerpt).not_to include('<!--more-->')
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
      let(:long_post) { create(:long_post) }

      it 'returns true' do
        expect(long_post.more_text?).to be true
      end
    end
  end

  describe 'next' do
    let!(:long_post) { create(:long_post, user: post.user) }

    it 'returns the next post' do
      expect(post.next).to eq(long_post)
    end

    it 'returns nil if no next post exists' do
      expect(long_post.next).to be_nil
    end
  end

  describe 'previous' do
    let(:long_post) { create(:long_post, user: post.user) }

    it 'returns the previous post' do
      expect(long_post.previous).to eq(post)
    end

    it 'returns nil if no previous post exists' do
      expect(post.previous).to be_nil
    end
  end
end
