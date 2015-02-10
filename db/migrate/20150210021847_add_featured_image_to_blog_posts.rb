class AddFeaturedImageToBlogPosts < ActiveRecord::Migration
  def change
    add_column :posts, :featured_image_url, :text
  end
end
