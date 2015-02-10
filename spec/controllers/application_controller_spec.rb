require 'rails_helper'

describe ApplicationController do
  describe 'set_meta_tags_title' do
    it 'sets the site meta tag' do
      controller.send(:set_meta_tags_title)
      expect(controller.send(:meta_tags).meta_tags['site']).to eql('benradler.com')
    end
  end

  describe 'set_body_class' do
    it 'sets the @body_class ivar' do
      controller.send(:set_body_class, 'test')
      expect(controller.instance_variable_get(:@body_class)).to eql('test-template')
    end
  end
end
