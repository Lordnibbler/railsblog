require 'rails_helper'
require 'tmpdir'

describe LabController do
  describe 'index' do
    it 'provides persisted Flickr photographs to the experiments' do
      photo = instance_double(
        FlickrPhoto,
        flickr_id: '123',
        as_stream_item: { description: 'City lights' },
        composition_analyzed?: true,
        composition_analysis: { 'summary' => 'Layered city scene' },
      )
      relation = double(limit: [photo])
      allow(FlickrPhoto).to receive(:order).with(Arel.sql('RANDOM()')).and_return(relation)

      get :index

      expected_photos = [{
        description: 'City lights', flickr_id: '123',
        composition_analysis: { 'summary' => 'Layered city scene' },
      }]
      expect(assigns(:photos)).to eq(expected_photos)
      expect(assigns(:body_class)).to eq('lab-template')
    end
  end

  describe 'test inventory' do
    it 'reads production counts without spec or CircleCI directories' do
      Dir.mktmpdir do |directory|
        root = Pathname.new(directory)
        root.join('config').mkpath
        inventory = { files: 39, examples: 161, ci: 'CircleCI' }
        root.join('config/test_inventory.json').write(inventory.to_json)
        allow(Rails).to receive(:root).and_return(root)
        allow(Rails.env).to receive(:production?).and_return(true)

        expect(controller.send(:test_status)).to eq(inventory)
      end
    end
  end
end
