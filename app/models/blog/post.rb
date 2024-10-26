#
# represents a blog post with a markdown (or HTML) formatted :body
#
class Blog::Post < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: %i[slugged finders]

  belongs_to :user
  validates :title,   presence: true, uniqueness: true
  validates :body,    presence: true

  scope :published, -> { where(published: true) }
  scope :newest,    -> { order('created_at DESC') }

  paginates_per 5

  has_one_attached :featured_image
  has_many_attached :images

  EXCERPT_TAG = '<!--more-->'.freeze

  def self.ransackable_attributes(_auth_object = nil)
    %w[body created_at description id published slug title updated_at user_id]
  end

  #
  # @return [String] human-readable name of the author
  #
  def author
    user.name.titleize
  end

  #
  # @return [String] the post's content split at the EXCERPT_TAG tag
  # @note if no EXCERPT_TAG present, entire :body is returned
  #
  def excerpt
    body.split(EXCERPT_TAG).first
  end

  #
  # @return [Boolean] is there more body beyond the EXCERPT_TAG tag?
  #
  def more_text?
    body != excerpt
  end

  def next
    self.user.posts.published.where('id > ? ', id).last
  end

  def previous
    self.user.posts.published.where(id: ...id).last
  end
end
