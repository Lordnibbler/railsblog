# Derives broad gallery subjects from persisted Flickr metadata and vision analysis.
class PhotoSubjectClassifier
  SUBJECT_TERMS = {
    people: %w[person people man men woman women child children pedestrian performer worker rider crowd couple
               protester vendor skater],
    animals: %w[animal dog cat bird horse pet],
    street: %w[street sidewalk road crosswalk alley storefront urban city traffic],
    landscape: %w[landscape sky cloud ocean sea beach mountain hill tree forest horizon water nature shore],
    architecture: %w[architecture architectural building facade window door bridge stair stairs structure tower],
    transit: %w[car vehicle bus train tram bicycle bike motorcycle truck taxi airplane plane],
  }.freeze
  SUBJECT_PATTERNS = SUBJECT_TERMS.transform_values do |terms|
    Regexp.new("\\b(?:#{terms.join('|')})\\b", Regexp::IGNORECASE)
  end.freeze

  def self.call(photo)
    analysis = photo.respond_to?(:composition_analysis) ? photo.composition_analysis.to_h : {}
    text = [
      photo.photo_data['title'], photo.photo_data['description'], analysis['summary'],
      *Array(analysis['techniques']).flat_map do |technique|
        technique.values_at('title', 'explanation')
      end,
    ].compact.join(' ')

    SUBJECT_PATTERNS.filter_map { |subject, pattern| subject if text.match?(pattern) }
  end
end
