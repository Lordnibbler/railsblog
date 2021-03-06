atom_feed do |feed|
  feed.title('Ben Radler\'s Blog')
  feed.updated(@posts[0].created_at) unless @posts.empty?

  @posts.each do |post|
    feed.entry(post, url: blog_posts_permalink_path(post)) do |entry|
      entry.title(post.title)
      entry.body(markdown(post.body), type: 'html')
      entry.author do |author|
        author.name(post.author)
      end
    end
  end
end
