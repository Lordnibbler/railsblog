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

  it 'warms and marks the cache without clearing existing entries' do
    allow(Rails.cache).to receive(:clear)
    allow(Rails.cache).to receive(:write)
    allow(FlickrService).to receive(:warm_cache_shuffled)

    task.invoke

    expect(FlickrService).to have_received(:warm_cache_shuffled)
    expect(Rails.cache).not_to have_received(:clear)
    expect(Rails.cache).to have_received(:write).with(
      FlickrService::PHOTOGRAPHY_CACHE_WARMED_KEY,
      true,
      expires_in: 25.hours,
    )
    expect(logger).to have_received(:info).with('--->  Cache Warmer: Warming Flickr cache')
    expect(logger).to have_received(:info).with('--->  Cache Warmer: completed warming cache')
    expect(logger).to have_received(:info).with('--->  Cache Warmer: finished in 2.34s')
  end

  it 'logs elapsed time when warming fails' do
    allow(FlickrService).to receive(:warm_cache_shuffled).and_raise(Net::ReadTimeout)

    expect { task.invoke }.to raise_error(Net::ReadTimeout)

    expect(logger).to have_received(:info).with('--->  Cache Warmer: finished in 2.34s')
  end
end
# rubocop:enable RSpec/DescribeClass
