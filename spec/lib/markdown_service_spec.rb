require 'rails_helper'

describe MarkdownService do
  describe '.call' do
    context 'with standard markdown' do
      let(:markdown) do
        "# This is a header!\r\n\r\nthis is some markdown\r\n\r\n* this is a list\r\n* and so is " \
          "this\r\n  * and a sub list item\r\n  * and another"
      end

      let(:html) do
        "<h1>This is a header!</h1>\n\n<p>this is some markdown</p>\n\n<ul>\n<li>this is a list"   \
          "</li>\n<li>and so is this\n\n<ul>\n<li>and a sub list item</li>\n<li>and another</li>"  \
          "\n</ul></li>\n</ul>\n"
      end

      it 'turns markdown into HTML' do
        expect(MarkdownService.call(markdown)).to eql(html)
      end
    end

    context 'with fenced code blocks' do
      let(:fenced_markdown) do
        "```ruby\r\n# this is some ruby code\r\ndef foo(bar = 'baz')\r\n  puts bar\r\nend\r\n```"
      end

      let(:fenced_html) do
        "<pre class=\"highlight ruby\"><code><span class=\"c1\"># this is some ruby code</span>\n" \
          "<span class=\"k\">def</span> <span class=\"nf\">foo</span><span class=\"p\">(</span>"   \
          "<span class=\"n\">bar</span> <span class=\"o\">=</span> <span class=\"s1\">'baz'"       \
          "</span><span class=\"p\">)</span>\n  <span class=\"nb\">puts</span> <span class=\"n\">" \
          "bar</span>\n<span class=\"k\">end</span>\n</code></pre>\n"
      end

      it 'returns formatted <code>' do
        expect(MarkdownService.call(fenced_markdown)).to eql(fenced_html)
      end
    end
  end
end
