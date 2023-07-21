require 'rails_helper'

describe ApplicationHelper do
  describe 'meta_title' do
    let(:title) { 'Bacon ipsum dolor amet sirloin shank leberkas, andouille short ribs bacon' }
    let(:short_title) { 'Bacon ipsum dolor amet sirloin shank leberkas,' }

    it 'returns a truncated title' do
      expect(helper.meta_title(title).length).not_to eql(title.length)
      expect(helper.meta_title(title)).to eql(short_title)
      expect(helper.meta_title(title).length).not_to be > 70
    end
  end

  describe 'meta_description_markdown' do
    let(:description) do
      '# Bacon ipsum dolor amet meatball ball tip jowl biltong brisket andouille picanha shankle ' \
        'shoulder landjaeger frankfurter tri-tip ribeye. Drumstick ham hock doner pork chop'
    end

    let(:short_description) do
      'Bacon ipsum dolor amet meatball ball tip jowl biltong brisket andouille picanha shankle ' \
        'shoulder landjaeger frankfurter tri-tip ribeye. Drumstick ham hock doner'
    end

    it 'returns a truncated meta description without markdown' do
      expect(helper.meta_description_markdown(description)).not_to eql(description)
      expect(helper.meta_description_markdown(description)).to eql(short_description)
      expect(helper.meta_description_markdown(description).size).not_to be > 160
      expect(helper.meta_description_markdown(description)).not_to include('#', '*', '>')
    end
  end

  describe 'meta_description' do
    let(:description) do
      'Bacon ipsum dolor amet meatball ball tip jowl biltong brisket andouille picanha shankle ' \
        'shoulder landjaeger frankfurter tri-tip ribeye. Drumstick ham hock doner pork chop'
    end

    let(:short_description) do
      'Bacon ipsum dolor amet meatball ball tip jowl biltong brisket andouille picanha shankle ' \
        'shoulder landjaeger frankfurter tri-tip ribeye. Drumstick ham hock doner'
    end

    it 'returns a truncated meta description' do
      expect(helper.meta_description_markdown(description)).not_to eql(description)
      expect(helper.meta_description_markdown(description)).to eql(short_description)
      expect(helper.meta_description_markdown(description).size).not_to be > 160
    end
  end

  describe 'main_styles' do
    it 'returns empty string for photography_path' do
      allow(helper).to receive(:current_page?).and_return(true)

      expect(helper.main_styles).to eql('')
    end

    it 'returns appropriate styles for non-photography_path' do
      allow(helper).to receive(:current_page?).and_return(false)

      expect(helper.main_styles).to eql('height: 100vh; height: var(--app-height, 100vh);')
    end
  end

  describe 'navigation_class' do
    it 'returns appropriate styles for root_path' do
      allow(helper).to receive(:current_page?).and_return(true)

      expect(helper.navigation_class).to eql('bg-primary/0 dark:bg-primary-50/0')
    end

    it 'returns appropriate styles for non-root_path' do
      allow(helper).to receive(:current_page?).and_return(false)

      expect(helper.navigation_class).to eql('bg-primary dark:bg-primary-50')
    end
  end

  describe 'desktop_navigation_link' do
    it 'returns a desktop navigation link HTML' do
      link = helper.desktop_navigation_link(name: 'Home', path: root_path)

      # rubocop:disable Layout/LineLength
      expect(link).to eq('<li class="group pl-6"><a class="font-header font-semibold text-white uppercase py-2 cursor-pointer hover:underline underline-offset-8 decoration-2 decoration-yellow" href="/">Home</a></li>')
      # rubocop:enable Layout/LineLength
    end
  end

  describe 'scrolling_desktop_navigation_link' do
    context 'when request_path is "/"' do
      before { helper.request.path = '/' }

      it 'returns a desktop navigation link HTML for the homepage' do
        link = helper.scrolling_desktop_navigation_link(name: 'Videos', path: '#videos')

        # rubocop:disable Layout/LineLength
        expect(link).to eq('<li class="group pl-6"><a x-on:click="triggerNavItem(&#39;#videos&#39;)" class="font-header font-semibold text-white uppercase py-2 cursor-pointer hover:underline underline-offset-8 decoration-2 decoration-yellow">Videos</a></li>')
        # rubocop:enable Layout/LineLength
      end
    end

    context 'when request_path is nil' do
      it 'returns a desktop navigation link HTML for pages other than homepage' do
        link = helper.scrolling_desktop_navigation_link(name: 'Videos', path: '#videos')

        # rubocop:disable Layout/LineLength
        expect(link).to eq('<li class="group pl-6"><a href="/#videos" data-turbo="false" class="font-header font-semibold text-white uppercase py-2 cursor-pointer hover:underline underline-offset-8 decoration-2 decoration-yellow">Videos</a></li>')
        # rubocop:enable Layout/LineLength
      end
    end
  end

  describe 'mobile_navigation_link' do
    it 'returns a mobile navigation link HTML' do
      link = helper.mobile_navigation_link(name: 'Home', path: root_path)

      # rubocop:disable Layout/LineLength
      expect(link).to eq('<li class="pb-4"><a class="font-header font-semibold text-2xl text-white uppercase py-2 cursor-pointer hover:underline underline-offset-8 decoration-2 decoration-yellow" href="/">Home</a></li>')
      # rubocop:enable Layout/LineLength
    end
  end

  describe 'scrolling_mobile_navigation_link' do
    context 'when request_path is "/"' do
      before { helper.request.path = '/' }

      it 'returns a mobile navigation link HTML for the homepage' do
        link = helper.scrolling_mobile_navigation_link(name: 'Videos', path: '#videos')

        # rubocop:disable Layout/LineLength
        expect(link).to eq('<li class="pb-4"><a x-on:click="triggerMobileNavItem(&#39;#videos&#39;)" class="font-header font-semibold text-2xl text-white uppercase py-2 cursor-pointer hover:underline underline-offset-8 decoration-2 decoration-yellow">Videos</a></li>')
        # rubocop:enable Layout/LineLength
      end
    end

    context 'when request_path is nil' do
      it 'returns a mobile navigation link HTML for pages other than homepage' do
        link = helper.scrolling_mobile_navigation_link(name: 'Videos', path: '#videos')

        # rubocop:disable Layout/LineLength
        expect(link).to eq('<li class="pb-4"><a href="/#videos" data-turbo="false" class="font-header font-semibold text-2xl text-white uppercase py-2 hover:underline underline-offset-8 decoration-2 decoration-yellow">Videos</a></li>')
        # rubocop:enable Layout/LineLength
      end
    end
  end
end
