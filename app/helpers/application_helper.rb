#
# helper methods for views used application-wide
#
module ApplicationHelper
  PROFESSIONAL_START_YEAR = 2011
  DESKTOP_NAVIGATION_CLASSES = %w[
    font-header font-semibold text-white uppercase py-2 cursor-pointer hover:underline underline-offset-8
    decoration-2 decoration-yellow
  ].join(' ').freeze
  MOBILE_NAVIGATION_CLASSES = %w[
    font-header font-semibold text-2xl text-white uppercase py-2 cursor-pointer hover:underline underline-offset-8
    decoration-2 decoration-yellow
  ].join(' ').freeze
  MOBILE_LINK_NAVIGATION_CLASSES = %w[
    font-header font-semibold text-2xl text-white uppercase py-2 hover:underline underline-offset-8 decoration-2
    decoration-yellow
  ].join(' ').freeze

  def professional_experience_years
    Time.current.year - PROFESSIONAL_START_YEAR
  end

  def site_description
    "Ben Radler is a software engineer with #{professional_experience_years} years of experience building " \
      'dependable, high-scale systems for companies including Cruise, Lyft, Teespring, and OneLogin.'
  end

  def current_page_url
    request&.original_url || root_url
  end

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
    current_page?(photography_path) ? '' : 'min-height: 100vh; min-height: var(--app-height, 100vh);'
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
    content_tag(:li, class: 'group pl-4 xl:pl-6') do
      link_to(
        name,
        path,
        class: DESKTOP_NAVIGATION_CLASSES,
      )
    end
  end

  #
  # @return [String] desktop navigation link for links that scroll the homepage when clicked,
  # or link visitor pre-scrolled to the section
  #
  def scrolling_desktop_navigation_link(name:, path:)
    content_tag(:li, class: 'group pl-4 xl:pl-6') do
      if request.path == '/'
        content_tag(
          :a,
          name,
          'x-on:click': "triggerNavItem('#{path}')",
          class: DESKTOP_NAVIGATION_CLASSES,
        )
      else
        content_tag(
          :a,
          href: "#{root_path}#{path}", 'data-turbo': 'false',
          class: DESKTOP_NAVIGATION_CLASSES,
        ) do
          name
        end
      end
    end
  end

  #
  # @return [String] mobile navigation link for links that dont scroll the homepage when clicked
  #
  def mobile_navigation_link(name:, path:)
    content_tag(:li, class: 'pb-4') do
      link_to(
        name,
        path,
        class: MOBILE_NAVIGATION_CLASSES,
      )
    end
  end

  #
  # @return [String] mobile navigation link for links that scroll the homepage when clicked,
  # or link visitor pre-scrolled to the section
  #
  def scrolling_mobile_navigation_link(name:, path:)
    content_tag(:li, class: 'pb-4') do
      if request.path == '/'
        content_tag(
          :a,
          name,
          'x-on:click': "triggerMobileNavItem('#{path}')",
          class: MOBILE_NAVIGATION_CLASSES,
        )
      else
        content_tag(
          :a,
          href: "#{root_path}#{path}",
          'data-turbo': 'false',
          class: MOBILE_LINK_NAVIGATION_CLASSES,
        ) do
          name
        end
      end
    end
  end
end
