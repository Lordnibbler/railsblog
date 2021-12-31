class RemoveFeaturedImageUrlFromBlogPosts < ActiveRecord::Migration[6.1]
  def change
    remove_column :posts, :featured_image_url, :text
  end
end
