#
# helper methods for views used application-wide
#
module ApplicationHelper
  #
  # @return [String] a <=55 character meta title
  #
  def meta_title(title)
    truncate(title, length: 55, separator: ' ', omission: '')
  end

  #
  # @return [String] a <=160 character meta description for a markdown-formatted string
  # @param [String] a markdown formatted string
  #
  def meta_description_markdown(markdown)
    html = MarkdownService.call(markdown)
    meta_description(html)
  end

  #
  # @return [String] a <=160 character meta description for a markdown-formatted string
  #
  def meta_description(description)
    truncate(strip_tags(description), length: 160, separator: ' ', omission: '')
  end

  #
  # @return [String] desktop navigation link for links that dont scroll the homepage when clicked
  #
  def desktop_navigation_link(name:, path:)
    content_tag(:li, class: "group pl-6") do
      span_1 = content_tag(:span, class: "font-header font-semibold text-white uppercase pt-0.5 cursor-pointer") do
        link_to name, path
      end
      span_2 = content_tag(:span, class: "block w-full h-0.5 bg-transparent group-hover:bg-yellow") do
      end

      span_1 + span_2
    end
  end

  #
  # @return [String] desktop navigation link for links that scroll the homepage when clicked, or link visitor pre-scrolled to the section
  #
  def scrolling_desktop_navigation_link(name:, path:)
    content_tag(:li, class: "group pl-6") do
      span_1 = if request.path == '/'
        raw("<a @click=\"triggerNavItem('#{path}')\" class=\"font-header font-semibold text-white uppercase pt-0.5 cursor-pointer\">#{name}</a>")
      else
        content_tag(:a, href: "#{root_path}#{path}", "data-turbo": "false", class: "font-header font-semibold text-white uppercase pt-0.5 cursor-pointer") do
          raw(name)
        end
      end

      span_2 = content_tag(:span, class: "block w-full h-0.5 bg-transparent group-hover:bg-yellow") do
      end

      span_1 + span_2
    end
  end

    #
  # @return [String] mobile navigation link for links that dont scroll the homepage when clicked
  #
  def mobile_navigation_link(name:, path:)
    content_tag(:li, class: "py-2") do
      span_1 = content_tag(:span, class: "font-header font-semibold text-white uppercase pt-0.5 cursor-pointer") do
        link_to name, path
      end
    end
  end


  #
  # @return [String] mobile navigation link for links that scroll the homepage when clicked, or link visitor pre-scrolled to the section
  #
  def scrolling_mobile_navigation_link(name:, path:)
    content_tag(:li, class: "py-2") do
      span_1 = if request.path == '/'
        raw("<span @click=\"triggerMobileNavItem('#{path}')\" class=\"font-header font-semibold text-white uppercase pt-0.5 cursor-pointer\">#{name}</span>")
      else
        content_tag(:a, href: "#{root_path}#{path}", class: "font-header font-semibold text-white uppercase pt-0.5") do
          raw(name)
        end
      end

      span_2 = content_tag(:span, class: "block w-full h-0.5 bg-transparent group-hover:bg-yellow") do
      end

      span_1 + span_2
    end
  end
end
