class NewsletterSignup < ApplicationRecord
    validates :email, format: { with: /\A[^@\s]+@[^@\s]+\z/i, message: "is invalid" }
end
