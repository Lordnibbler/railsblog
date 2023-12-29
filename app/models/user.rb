#
# represents an admin user for activeadmin, owner of blog posts
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable

  has_many :posts, dependent: :destroy, class_name: 'Blog::Post'

  def self.ransackable_attributes(_auth_object = nil)
    %w[
      avatar_url
      biography
      created_at
      current_sign_in_at
      current_sign_in_ip
      email
      encrypted_password
      id
      last_sign_in_at
      last_sign_in_ip
      name
      remember_created_at
      reset_password_sent_at
      reset_password_token
      sign_in_count updated_at
    ]
  end
end
