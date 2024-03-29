require 'rails_helper'

describe BlogHelper do
  describe 'markdown' do
    let(:html) { '<h1>some header</h1>' }

    it 'calls the markdown_service#call method' do
      allow(MarkdownService).to receive(:call) { html }
      expect(helper.markdown('# some header')).to match(/#{html}/)
      expect(MarkdownService).to have_received(:call)
    end
  end

  describe 'blog_posts_permalink_path' do
    let(:post) { create(:post) }
    let(:date) { post.created_at.strftime('%Y/%m/%d') }

    it 'returns permalink-formatted path to post' do
      expect(helper.blog_posts_permalink_path(post)).to eql("/blog/#{date}/i-love-bacon")
    end
  end
end
