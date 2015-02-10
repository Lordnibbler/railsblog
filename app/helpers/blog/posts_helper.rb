module Blog::PostsHelper
  #
  # @return [String] a <=55 character meta title for a post based on its title
  #
  def meta_title(title)
    truncate(title, length: 55, separator: ' ')
  end

  #
  # @return [String] a <=160 character meta description for a markdown-formatted string
  # @param [String] a markdown formatted string
  #
  def meta_description_markdown(md)
    html = markdown(md)
    meta_description(html)
  end

  #
  # @return [String] a <=160 character meta description for a markdown-formatted string
  #
  def meta_description(description)
    truncate(strip_tags(description), length: 160, separator: ' ', omission: '')
  end
end
