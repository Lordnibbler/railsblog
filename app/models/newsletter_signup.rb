class NewsletterSignup < ApplicationRecord
    validates :email, format: { with: /\A[^@\s]+@[^@\s]+\z/i, message: "is invalid" }
    validates :email, uniqueness: { message: "is already signed up for the newsletter." }
end
