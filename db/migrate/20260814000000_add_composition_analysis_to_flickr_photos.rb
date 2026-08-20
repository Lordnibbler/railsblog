# Adds persisted vision-model readings for the Composition Studio.
class AddCompositionAnalysisToFlickrPhotos < ActiveRecord::Migration[8.1]
  def change
    change_table :flickr_photos, bulk: true do |table|
      table.jsonb :composition_analysis, default: {}, null: false
      table.datetime :composition_analyzed_at
      table.string :composition_analysis_version
      table.text :composition_analysis_error
      table.index :composition_analyzed_at
    end
  end
end
