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
  # sets main_styles ivar such that footer is stuck to bottom of page,
  # based on --app-height variable set on resize in custom.js
  #
  # this solves for iOS bug where navigation bar covers some of the page
  # and creates unnecessary scrollable area when there is minimal content on page.
  #
  # photography page has dynamically determined height by infinite-scroll,
  # so dont use --app-height js on photography_path
  #
  def main_styles
    current_page?(photography_path) ? "" : "height: 100vh; height: var(--app-height, 100vh);"
  end

  #
  # home page nav should be fully transparent until scrolling
  # all other pages require opaque bg
  #
  def navigation_class
    current_page?(root_path) ? 'bg-primary/0 dark:bg-primary-50/0' : 'bg-primary dark:bg-primary-50'
  end

  #
  # @return [String] desktop navigation link for links that dont scroll the homepage when clicked
  #
  def desktop_navigation_link(name:, path:)
    content_tag(:li, class: 'group pl-6') do
      span1 = content_tag(:span, class: 'font-header font-semibold text-white uppercase pt-0.5 cursor-pointer') do
        link_to name, path
      end
      span2 = content_tag(:span, '', class: 'block w-full h-0.5 bg-transparent group-hover:bg-yellow')

      span1 + span2
    end
  end

  #
  # @return [String] desktop navigation link for links that scroll the homepage when clicked,
  # or link visitor pre-scrolled to the section
  #
  # rubocop:disable Layout/LineLength
  def scrolling_desktop_navigation_link(name:, path:)
    content_tag(:li, class: 'group pl-6') do
      span1 = if request.path == '/'
                content_tag(:a, name, '@click': "triggerNavItem('#{path}')", class: 'font-header font-semibold text-white uppercase pt-0.5 cursor-pointer')
              else
                content_tag(:a, href: "#{root_path}#{path}", 'data-turbo': 'false',
                                class: 'font-header font-semibold text-white uppercase pt-0.5 cursor-pointer',) do
                  name
                end
              end

      span2 = content_tag(:span, '', class: 'block w-full h-0.5 bg-transparent group-hover:bg-yellow')

      span1 + span2
    end
  end
  # rubocop:enable Layout/LineLength

  #
  # @return [String] mobile navigation link for links that dont scroll the homepage when clicked
  #
  def mobile_navigation_link(name:, path:)
    content_tag(:li, class: 'py-2') do
      content_tag(:span, class: 'font-header font-semibold text-2xl text-white uppercase pt-1 cursor-pointer') do
        link_to name, path
      end
    end
  end

  #
  # @return [String] mobile navigation link for links that scroll the homepage when clicked,
  # or link visitor pre-scrolled to the section
  #
  # rubocop:disable Layout/LineLength
  def scrolling_mobile_navigation_link(name:, path:)
    content_tag(:li, class: 'py-2') do
      span1 = if request.path == '/'
                content_tag(:a, name, '@click': "triggerMobileNavItem('#{path}')", class: 'font-header font-semibold text-2xl text-white uppercase pt-1 cursor-pointer')
              else
                content_tag(:a, href: "#{root_path}#{path}", 'data-turbo': 'false',
                                class: 'font-header font-semibold text-2xl text-white uppercase pt-1',) do
                  name
                end
              end

      span2 = content_tag(:span, '', class: 'block w-full h-0.5 bg-transparent group-hover:bg-yellow')

      span1 + span2
    end
  end
  # rubocop:enable Layout/LineLength
end
