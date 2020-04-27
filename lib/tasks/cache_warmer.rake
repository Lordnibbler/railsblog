namespace :cache_warmer do
  # usage: bx rails 'cache_warmer:flickr[benradler-staging.herokuapp.com,8]'
  desc "Warms cache for flickr API"
  task :flickr, [:url, :num_pages] => :environment do |task, args|
    Rails.cache.clear
    threads = []
    num_pages = args[:num_pages].to_i
    (1..num_pages).each do |i|
      threads << Thread.new do
        url = "http://#{args[:url]}/api/v1/stream/flickr.json?page=#{i}"
        puts "warming cache for #{url}"
        `curl #{url}`
        puts "completed warming cache for #{url}"
      end
    end
    threads.each(&:join)
  end
end


