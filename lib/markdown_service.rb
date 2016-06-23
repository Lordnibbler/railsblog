require 'rouge/plugins/redcarpet'

#
# markdown service converts markdown into HTML, including fenced code blocks
# @see http://www.watchsumo.com/posts/adding-github-flavoured-markdown-with-syntax-highlighting-in-your-rails-application
#
class MarkdownService
  #
  # enable rouge in redcarpet
  #
  class Renderer < Redcarpet::Render::HTML
    include Rouge::Plugins::Redcarpet
  end

  attr_reader :markdown

  def initialize(markdown)
    @markdown = markdown
  end

  #
  # public API to invoke the MarkdownService
  # @example MarkdownService.call('# markdown')
  #
  def self.call(markdown)
    new(markdown).call
  end

  def call
    render
  end

  private

  #
  # @return [Redcarpet::Markdown] a redcarpet markdown renderer instance
  #
  def markdown_renderer
    Redcarpet::Markdown.new(Renderer,
      autolink: true,
      tables: true,
      fenced_code_blocks: true,
      line_numbers: true)
  end

  #
  # @return [String] render {markdown} as an HTML string
  #
  def render
    markdown_renderer.render(markdown)
  end
end
