#
# helper methods for rendering markdown, syntax highlighted code, generating permalink paths
#
module BlogHelper
  #
  # @return [String] {text} rendered as HTML
  #
  def markdown(text)
    simple_format(MarkdownService.call(text))
  end

  #
  # @return [String] path to a permalink with the created_at date of Blog::Post
  # @example
  #   blog_posts_permalink_path(Blog::Post.new(created_at: Time.now))
  #   # => localhost:3000/2015/02/01/:title
  #
  def blog_posts_permalink_path(post)
    date = post.created_at
    blog_permalink_path(
      year:  date.strftime('%Y'),
      month: date.strftime('%m'),
      day:   date.strftime('%d'),
      id:    post.slug
    )
  end
end
