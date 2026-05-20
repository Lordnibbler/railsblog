require 'rails_helper'
require 'rake'

describe 'cache_warmer:flickr' do
  let(:task) { Rake::Task['cache_warmer:flickr'] }
  let(:logger) { instance_double(Logger, info: nil) }

  before(:all) do
    Rails.application.load_tasks
  end

  before do
    task.reenable
    allow(Rails).to receive(:logger).and_return(logger)
    allow(Process).to receive(:clock_gettime).with(Process::CLOCK_MONOTONIC).and_return(10.0, 12.34)
  end

  it 'exits without warming when the cache is already warm' do
    allow(Rails.cache).to receive(:fetch).with(FlickrService::PHOTOGRAPHY_CACHE_WARMED_KEY).and_return(true)
    allow(Rails.cache).to receive(:clear)
    allow(Rails.cache).to receive(:write)
    allow(FlickrService).to receive(:warm_cache_shuffled)

    task.invoke

    expect(FlickrService).not_to have_received(:warm_cache_shuffled)
    expect(Rails.cache).not_to have_received(:clear)
    expect(Rails.cache).not_to have_received(:write)
    expect(logger).to have_received(:info).with('--->  Cache Warmer: Cache already warm, exiting')
    expect(logger).to have_received(:info).with('--->  Cache Warmer: finished in 2.34s')
  end

  it 'warms and marks the cache without clearing existing entries' do
    allow(Rails.cache).to receive(:fetch).with(FlickrService::PHOTOGRAPHY_CACHE_WARMED_KEY).and_return(false)
    allow(Rails.cache).to receive(:clear)
    allow(Rails.cache).to receive(:write)
    allow(FlickrService).to receive(:warm_cache_shuffled)

    task.invoke

    expect(FlickrService).to have_received(:warm_cache_shuffled)
    expect(Rails.cache).not_to have_received(:clear)
    expect(Rails.cache).to have_received(:write).with(
      FlickrService::PHOTOGRAPHY_CACHE_WARMED_KEY,
      true,
      expires_in: 1.day,
    )
    expect(logger).to have_received(:info).with('--->  Cache Warmer: finished in 2.34s')
  end

  it 'logs elapsed time when warming fails' do
    allow(Rails.cache).to receive(:fetch).with(FlickrService::PHOTOGRAPHY_CACHE_WARMED_KEY).and_return(false)
    allow(FlickrService).to receive(:warm_cache_shuffled).and_raise(Net::ReadTimeout)

    expect { task.invoke }.to raise_error(Net::ReadTimeout)

    expect(logger).to have_received(:info).with('--->  Cache Warmer: finished in 2.34s')
  end
end
