xml.instruct! :xml, version: '1.0'
xml.rss version: '2.0' do
  xml.channel do
    xml.title 'benradler.com'
    xml.description 'A Blog about Technology'
    xml.link blog_posts_path

    @posts.each do |post|
      xml.item do
        xml.title post.title
        xml.description post.body
        xml.pubDate post.created_at.to_s(:rfc822)
        xml.link blog_posts_permalink_path(post)
        xml.guid blog_posts_permalink_path(post)
      end
    end
  end
end
