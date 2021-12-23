require 'rails_helper'

describe ApplicationController do
  describe 'set_meta_tags_title' do
    it 'sets the site meta tag' do
      controller.send(:set_meta_tags_title)
      expect(controller.send(:meta_tags).meta_tags['site']).to eql('benradler.com')
    end
  end

  describe 'body_class' do
    it 'sets the @body_class ivar' do
      controller.send(:body_class, 'test')
      expect(controller.instance_variable_get(:@body_class)).to eql('test-template')
    end

    it 'allows prefixing the template class' do
      controller.send(:body_class, 'bg-primary test')
        expect(controller.instance_variable_get(:@body_class)).to eql('bg-primary test-template')
    end
  end
end
