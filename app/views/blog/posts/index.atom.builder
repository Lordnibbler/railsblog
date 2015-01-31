atom_feed do |feed|
  feed.title('Ben Radler\'s Blog')
  feed.updated(@posts[0].created_at) if @posts.length > 0

  @posts.each do |post|
    feed.entry(post, url: blog_post_url(post)) do |entry|
      entry.title(post.title)
      entry.content(markdown(post.content), type: 'html')
      entry.author do |author|
        author.name(post.author)
      end
    end
  end
end
