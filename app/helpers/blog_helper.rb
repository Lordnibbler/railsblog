require 'markdown_service'

#
# helper methods for rendering markdown, syntax highlighted code, generating permalink paths
#
module BlogHelper
  #
  # @return [String] {text} rendered as HTML
  #
  # rubocop:disable Rails/OutputSafety
  def markdown(text)
    MarkdownService.call(text).html_safe
  end
  # rubocop:enable Rails/OutputSafety

  #
  # @return [String] path to a permalink with the created_at date of Blog::Post
  # @example
  #   blog_posts_permalink_path(Blog::Post.new(created_at: Time.now))
  #   # => localhost:3000/2015/02/01/:title
  #
  def blog_posts_permalink_path(post)
    date = post.created_at
    blog_permalink_path(
      year: date.strftime('%Y'),
      month: date.strftime('%m'),
      day: date.strftime('%d'),
      id: post.slug,
    )
  end
end
