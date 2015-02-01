require 'rouge/plugins/redcarpet'

#
# markdown service converts markdown into HTML, including fenced code blocks
# @see http://www.watchsumo.com/posts/adding-github-flavoured-markdown-with-syntax-highlighting-in-your-rails-application
#
class MarkdownService
  class Renderer < Redcarpet::Render::HTML
    include Rouge::Plugins::Redcarpet
  end

  attr_reader :markdown

  def self.call(markdown)
    new(markdown).call
  end

  def initialize(markdown)
    @markdown = markdown
  end

  def call
    render
  end

  private

  def markdown_renderer
    Redcarpet::Markdown.new(Renderer,
      autolink: true,
      tables: true,
      fenced_code_blocks: true,
      line_numbers: true
    )
  end

  def render
    markdown_renderer.render(markdown)
  end
end
