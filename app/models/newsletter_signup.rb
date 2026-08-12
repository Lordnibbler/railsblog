# records any signup for the newsletter on the homepage
class NewsletterSignup < ApplicationRecord
  before_validation :normalize_email

  validates :email, format: { with: /\A[^@\s]+@[^@\s]+\z/i, message: 'is invalid' }
  validates :email, uniqueness: { message: 'is already signed up for the newsletter.' }

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
