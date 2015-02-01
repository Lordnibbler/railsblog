#
# helper methods for rendering markdown, syntax highlighted code
#
module BlogHelper
  #
  # helper method to render markdown-formatted text to HTML in a rails view
  #
  def markdown(text)
    MarkdownService.call(text).html_safe
  end
end
