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
  # @return [Array<Blog::Post>] all Blog::Post .md files located in {posts_path} sorted by newest
  #
  def self.all
    post_files
      .map { |file| self.new extract_data_from(file) }
      .sort_by { |post| post.created_at }
      .reverse!
  end

  #
  # @return [Blog::Post] Blog::Post matching the {name} parameter
  #
  def self.find_by_name(name)
    self.new extract_data_from(find_file_by(name))
  end

  private

  #
  # @return [Array<Blog::Post>] sorted by date created
  #
  def self.post_files
    Dir.glob("#{posts_path}/*.md")
  end

  #
  # @return [String] full path to .md file in posts_path that matches {name}
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
  # @return [Hash] post data from {file}, including yaml frontmatter
  #
  def self.extract_data_from(file)
    { content: File.read(file), permalink: File.basename(file, '.*') }
      .merge(yaml_frontmatter_metadata_from(file))
  end

  #
  # @return [HashWithIndifferentAccess] YAML frontmatter metadata
  #
  def self.yaml_frontmatter_metadata_from(file)
    HashWithIndifferentAccess.new(YAML.load_file(file))
  end

  # def self.generate_permalink_from(file)
  #   date = yaml_frontmatter_metadata_from(file)[:created_at].to_date.strftime('%Y/%m/%d')
  #   "#{date}/#{File.basename(file, '.*')}"
  # end

  #
  # @return [String] sanitized string with YAML frontmatter removed
  #
  def remove_yaml_frontmatter_from(text)
    text.sub(/^\s*---(.*?)---\s/m, '')
  end
end
