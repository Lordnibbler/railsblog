require 'rails_helper'
require 'rake'

Rails.application.load_tasks

# rubocop:disable RSpec/DescribeClass
describe 'cache_warmer:flickr' do
  let(:task) { Rake::Task['cache_warmer:flickr'] }
  let(:logger) { instance_double(Logger, info: nil) }

  before do
    task.reenable
    allow(Rails).to receive(:logger).and_return(logger)
    allow(Process).to receive(:clock_gettime).with(Process::CLOCK_MONOTONIC).and_return(10.0, 12.34)
  end

  it 'synchronizes Flickr photos' do
    allow(FlickrService).to receive(:sync_photos)

    task.invoke

    expect(FlickrService).to have_received(:sync_photos)
    expect(logger).to have_received(:info).with('--->  Flickr Sync: synchronizing photos')
    expect(logger).to have_received(:info).with('--->  Flickr Sync: completed synchronizing photos')
    expect(logger).to have_received(:info).with('--->  Cache Warmer: finished in 2.34s')
  end

  it 'logs elapsed time when warming fails' do
    allow(FlickrService).to receive(:sync_photos).and_raise(Net::ReadTimeout)

    expect { task.invoke }.to raise_error(Net::ReadTimeout)

    expect(logger).to have_received(:info).with('--->  Cache Warmer: finished in 2.34s')
  end
end
# rubocop:enable RSpec/DescribeClass
