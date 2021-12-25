class AddIndexToNewsletterSignups < ActiveRecord::Migration[6.1]
  def change
    add_index :newsletter_signups, :email, unique: true
  end
end
