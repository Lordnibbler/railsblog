class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.text :body
      t.string :title
      t.boolean :published
      t.timestamps null: false
      t.belongs_to :user, index: true
    end
  end
end
