#
# a single .md blog post
#
class Blog::Post
  include ActiveModel::Model
  attr_accessor :title, :content, :created_at, :permalink, :author

  #
  # @return [Fixnum] id used for the ATOM feed
  #
  def id
    @permalink.to_i
  end

  #
  # @return [String] the content with the YAML frontmatter metadata removed
  #
  def content
    remove_yaml_frontmatter_from @content
  end

  #
  # @return [String] the post's content split at the <!--more--> tag
  #
  def excerpt
    content.split('<!--more-->').first
  end

  #
  # @return [Boolean] is there more content beyond the <!--more--> tag?
  #
  def has_more_text?
    content != excerpt
  end

  #
  # @return [DateTime] when the post was created
  #
  def created_at
    @created_at.to_date
  end

  def to_param
    @permalink.parameterize
  end

  #
  # @return [Array<Blog::Post>] all Blog::Post .md files located in the {posts_path}
  #
  def self.all
    post_files.reverse.map do |file|
      self.new extract_data_from(file)
    end
  end

  #
  # @return [Blog::Post] Blog::Post matching the {name} parameter
  #
  def self.find_by_name(name)
    file = find_file_by(name)
    self.new extract_data_from(file)
  end

  private

  #
  #
  #
  def self.post_files
    sort_by_id Dir.glob("#{posts_path}/*.md")
  end

  #
  #
  #
  def self.sort_by_id(files)
    files.sort_by { |x| File.basename(x, '.*').to_i }
  end

  #
  #
  #
  def self.find_file_by(name)
    id = post_files.index { |x| x =~ /#{name}.md/ }
    post_files[id]
  end

  #
  # @return [String] path to published Blog::Post .md files
  #
  def self.posts_path
    Rails.root.join('app', 'views', 'blog', 'published').to_s
  end

  #
  # @return [Hash]
  #
  def self.extract_data_from(file)
    { content: File.read(file), permalink: File.basename(file, '.*') }
      .merge(yaml_frontmatter_metadata_from(file))
  end

  #
  # @return [] YAML frontmatter metadata
  #
  def self.yaml_frontmatter_metadata_from(file)
    YAML.load_file(file)
  end

  #
  # @return [String] sanitized string with YAML frontmatter removed
  #
  def remove_yaml_frontmatter_from(text)
    text.sub(/^\s*---(.*?)---\s/m, '')
  end
end
