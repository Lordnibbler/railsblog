require 'rouge/plugins/redcarpet'

#
# markdown service converts markdown into HTML, including fenced code blocks
# @see http://www.watchsumo.com/posts/adding-github-flavoured-markdown-with-syntax-highlighting-in-your-rails-application
#
class MarkdownService
  #
  # Create a custom renderer that sets custom classes for certain elements.
  #
  class Renderer < Redcarpet::Render::HTML
    # enable rouge language syntax highlighter in redcarpet
    include Rouge::Plugins::Redcarpet

    def link(link, title, content)
      %(<a href="#{link}" title="#{title}" class="dark:text-primary-500">#{content}</a>)
    end

    def header(text, header_level)
      %(<h#{header_level} class="dark:text-primary-1000">#{text}</h#{header_level}>)
    end


    def block_quote(quote)
      %(<blockquote class="dark:text-primary-1000">#{quote}</blockquote>)
    end

    def double_emphasis(text)
      %(<strong class="dark:text-primary-1000">#{text}</strong>)
    end

    def codespan(code)
      %(<code class="dark:text-primary-1000">#{ERB::Util.h(code)}</code>)
    end
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
    Redcarpet::Markdown.new(
      Renderer,
      autolink: true,
      tables: true,
      fenced_code_blocks: true,
      line_numbers: true,
    )
  end

  #
  # @return [String] render {markdown} as an HTML string
  #
  def render
    markdown_renderer.render(markdown)
  end
end
