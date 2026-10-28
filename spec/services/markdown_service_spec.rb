require 'rails_helper'

describe MarkdownService do
  describe '.call' do
    it 'renders email autolinks as mailto links' do
      rendered = Nokogiri::HTML.fragment(described_class.call('<hello@example.com>'))

      expect(rendered.at_css('a')['href']).to eq('mailto:hello@example.com')
      expect(rendered.at_css('a').text).to eq('hello@example.com')
    end

    it 'preserves quotes in link titles without creating extra attributes' do
      rendered = Nokogiri::HTML.fragment(described_class.call(%q([Example](https://example.com 'A "quoted" title'))))
      link = rendered.at_css('a')

      expect(link['title']).to eq('A "quoted" title')
      expect(link.attribute_nodes.map(&:name)).to contain_exactly('href', 'title', 'class')
    end

    context 'with standard markdown' do
      let(:markdown) do
        "# This is a header!\r\n\r\nthis is some markdown\r\n\r\n* this is a list\r\n* and so is " \
          "this\r\n  * and a sub list item\r\n  * and another"
      end

      let(:html) do
        "<h1 class=\"dark:text-primary-1000\">This is a header!</h1>\n<p>this is some markdown</p>" \
          "\n\n<ul>\n<li>this is a list" \
          "</li>\n<li>and so is this\n\n<ul>\n<li>and a sub list item</li>\n<li>and another</li>" \
          "\n</ul></li>\n</ul>\n"
      end

      it 'turns markdown into HTML' do
        expect(described_class.call(markdown)).to eql(html)
      end
    end

    context 'with fenced code blocks' do
      let(:fenced_markdown) do
        "```ruby\r\n# this is some ruby code\r\ndef foo(bar = 'baz')\r\n  puts bar\r\nend\r\n```"
      end

      let(:fenced_html) do
        '<div class="highlight"><pre class="highlight ruby"><code><span class="c1">' \
          "# this is some ruby code</span>\n" \
          '<span class="k">def</span> <span class="nf">foo</span><span class="p">(</span>' \
          "<span class=\"n\">bar</span> <span class=\"o\">=</span> <span class=\"s1\">'baz'" \
          "</span><span class=\"p\">)</span>\n  <span class=\"nb\">puts</span> <span class=\"n\">" \
          "bar</span>\n<span class=\"k\">end</span>\n</code></pre></div>"
      end

      it 'returns formatted <code>' do
        expect(described_class.call(fenced_markdown)).to eql(fenced_html)
      end
    end

    context 'with deeply nested lists' do
      let(:markdown) do
        <<~MARKDOWN
          * first level
              * second level
                  * third level
                      * fourth level
        MARKDOWN
      end

      it 'preserves each level when list items use four-space indentation' do
        rendered = Nokogiri::HTML.fragment(described_class.call(markdown))

        expect(rendered.css('ul ul ul ul').text).to include('fourth level')
      end
    end
  end
end
