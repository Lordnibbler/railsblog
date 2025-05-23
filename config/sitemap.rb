require 'aws-sdk-s3'

SitemapGenerator::Interpreter.send :include, BlogHelper

# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = 'https://benradler.com'

# pick a place safe to write the files
SitemapGenerator::Sitemap.public_path = 'tmp/'

# store on S3 using Fog
SitemapGenerator::Sitemap.adapter = SitemapGenerator::AwsSdkAdapter.new(
  "#{ENV['FOG_DIRECTORY']}-#{Rails.env}", # benradler-sitemap-production
  aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
  aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
  aws_region: ENV['FOG_REGION'], # us-west-1
)

# inform the map cross-linking where to find the other maps
SitemapGenerator::Sitemap.sitemaps_host = "http://#{ENV['FOG_DIRECTORY']}.s3.amazonaws.com/"

# pick a namespace within your bucket to organize your maps
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end

  # /blog
  add blog_posts_path, priority: 0.7, changefreq: 'daily'

  # /blog/:year/:month/:day/:id
  Blog::Post.published.find_each do |post|
    add blog_posts_permalink_path(post), lastmod: post.updated_at
  end

  # /contact-me
  add page_path 'contact-me', changefreq: 'monthly'

  # /photography
  add photography_path, changefreq: 'monthly'
end
