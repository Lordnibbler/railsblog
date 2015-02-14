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
end
