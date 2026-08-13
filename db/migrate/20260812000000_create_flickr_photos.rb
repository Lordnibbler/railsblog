# Persists the normalized Flickr gallery and its scheduled display order.
class CreateFlickrPhotos < ActiveRecord::Migration[8.0]
  def change
    create_table :flickr_photos do |t|
      t.string :flickr_id, null: false
      t.jsonb :photo_data, null: false, default: {}
      t.integer :display_position, null: false

      t.timestamps
    end

    add_index :flickr_photos, :flickr_id, unique: true
    add_index :flickr_photos, :display_position, unique: true
  end
end
