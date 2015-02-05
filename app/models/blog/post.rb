class Blog::Post < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: [:slugged, :finders]

  belongs_to :user
  validates :user_id, presence: true

  scope :published, -> { where(published: true) }

  EXCERPT_TAG = '<!--more-->'

  #
  # @return [String] human-readable name of the author
  #
  def author
    user.name
  end

  #
  # @return [String] the post's content split at the EXCERPT_TAG tag
  #
  def excerpt
    body.split(EXCERPT_TAG).first
  end

  #
  # @return [Boolean] is there more body beyond the EXCERPT_TAG tag?
  #
  def has_more_text?
    body != excerpt
  end
end
