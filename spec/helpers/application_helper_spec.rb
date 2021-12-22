require 'rails_helper'

describe ApplicationHelper do
  describe 'meta_title' do
    let(:title) { 'Bacon ipsum dolor amet sirloin shank leberkas, andouille short ribs bacon' }
    let(:short_title) { 'Bacon ipsum dolor amet sirloin shank leberkas,' }
    it 'returns a truncated title' do
      expect(helper.meta_title(title).length).to_not eql(title.length)
      expect(helper.meta_title(title)).to eql(short_title)
      expect(helper.meta_title(title).length).to_not be > 70
    end
  end

  describe 'meta_description_markdown' do
    let(:description) do
      '# Bacon ipsum dolor amet meatball ball tip jowl biltong brisket andouille picanha shankle' \
        ' shoulder landjaeger frankfurter tri-tip ribeye. Drumstick ham hock doner pork chop'
    end

    let(:short_description) do
      'Bacon ipsum dolor amet meatball ball tip jowl biltong brisket andouille picanha shankle' \
        ' shoulder landjaeger frankfurter tri-tip ribeye. Drumstick ham hock doner'
    end

    it 'returns a truncated meta description without markdown' do
      expect(helper.meta_description_markdown(description)).to_not eql(description)
      expect(helper.meta_description_markdown(description)).to eql(short_description)
      expect(helper.meta_description_markdown(description).size).to_not be > 160
      expect(helper.meta_description_markdown(description)).to_not include('#', '*', '>')
    end
  end

  describe 'meta_description' do
    let(:description) do
      'Bacon ipsum dolor amet meatball ball tip jowl biltong brisket andouille picanha shankle' \
        ' shoulder landjaeger frankfurter tri-tip ribeye. Drumstick ham hock doner pork chop'
    end

    let(:short_description) do
      'Bacon ipsum dolor amet meatball ball tip jowl biltong brisket andouille picanha shankle' \
        ' shoulder landjaeger frankfurter tri-tip ribeye. Drumstick ham hock doner'
    end

    it 'returns a truncated meta description' do
      expect(helper.meta_description_markdown(description)).to_not eql(description)
      expect(helper.meta_description_markdown(description)).to eql(short_description)
      expect(helper.meta_description_markdown(description).size).to_not be > 160
    end
  end

  describe 'desktop_navigation_link' do
    it 'returns a desktop navigation link HTML' do
      link = helper.desktop_navigation_link(name: "Home", path: root_path)

      expect(link).to eq("<li class=\"group pl-6\"><span class=\"font-header font-semibold text-white uppercase pt-0.5 cursor-pointer\"><a href=\"/\">Home</a></span><span class=\"block w-full h-0.5 bg-transparent group-hover:bg-yellow\"></span></li>")
    end
  end

  describe 'scrolling_desktop_navigation_link' do
    context 'when request_path is "/"' do
      let(:request) { double('request', path: '/') }
      before { allow(helper).to receive(:request).and_return(request) }

      it 'returns a desktop navigation link HTML for the homepage' do
        link = helper.scrolling_desktop_navigation_link(name: "Videos", path: "#videos")

        expect(link).to eq("<li class=\"group pl-6\"><span @click=\"triggerNavItem('#videos')\" class=\"font-header font-semibold text-white uppercase pt-0.5 cursor-pointer\">Videos</span><span class=\"block w-full h-0.5 bg-transparent group-hover:bg-yellow\"></span></li>")
      end
    end

    context 'when request_path is nil' do
      it 'returns a desktop navigation link HTML for pages other than homepage' do
        link = helper.scrolling_desktop_navigation_link(name: "Videos", path: "#videos")

        expect(link).to eq("<li class=\"group pl-6\"><a href=\"/#videos\" class=\"font-header font-semibold text-white uppercase pt-0.5 cursor-pointer\">Videos</a><span class=\"block w-full h-0.5 bg-transparent group-hover:bg-yellow\"></span></li>")
      end
    end
  end

  describe 'mobile_navigation_link' do
    it 'returns a mobile navigation link HTML' do
      link = helper.mobile_navigation_link(name: "Home", path: root_path)

      expect(link).to eq("<li class=\"py-2\"><span class=\"font-header font-semibold text-white uppercase pt-0.5 cursor-pointer\"><a href=\"/\">Home</a></span></li>")
    end
  end

  describe 'scrolling_mobile_navigation_link' do
    context 'when request_path is "/"' do
      let(:request) { double('request', path: '/') }
      before { allow(helper).to receive(:request).and_return(request) }

      it 'returns a mobile navigation link HTML for the homepage' do
        link = helper.scrolling_mobile_navigation_link(name: "Videos", path: "#videos")

        expect(link).to eq("<li class=\"py-2\"><span @click=\"triggerMobileNavItem('#videos')\" class=\"font-header font-semibold text-white uppercase pt-0.5 cursor-pointer\">Videos</span><span class=\"block w-full h-0.5 bg-transparent group-hover:bg-yellow\"></span></li>")
      end
    end

    context 'when request_path is nil' do
      it 'returns a mobile navigation link HTML for pages other than homepage' do
        link = helper.scrolling_mobile_navigation_link(name: "Videos", path: "#videos")

        expect(link).to eq("<li class=\"py-2\"><a href=\"/#videos\" class=\"font-header font-semibold text-white uppercase pt-0.5\">Videos</a><span class=\"block w-full h-0.5 bg-transparent group-hover:bg-yellow\"></span></li>")
      end
    end
  end
end
