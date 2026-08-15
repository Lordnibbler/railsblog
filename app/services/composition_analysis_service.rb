require 'net/http'

# Produces conservative, photograph-specific composition readings with a
# vision-capable model. Results are persisted on FlickrPhoto so visitors never
# wait on, or receive credentials for, the external API.
# rubocop:disable Metrics/ClassLength
class CompositionAnalysisService
  VERSION = '2026-08-14-v2'.freeze
  ENDPOINT = URI('https://api.openai.com/v1/responses')
  TECHNIQUES = %w[
    thirds leading triangle odds layers space spiral pattern density
    frame symmetry juxtaposition color diagonal
  ].freeze

  class << self
    def configured?
      ENV['OPENAI_API_KEY'].present?
    end

    def analyze_pending(limit: ENV.fetch('COMPOSITION_ANALYSIS_LIMIT', 20).to_i, force: false)
      return 0 unless configured?

      scope = FlickrPhoto.order(:display_position)
      scope = scope.where(composition_analysis: {}) unless force
      scope = scope.limit(limit)
      scope.count { |photo| new(photo).analyze_and_persist }
    end
  end

  def initialize(photo, http: Net::HTTP)
    @photo = photo
    @http = http
  end

  def analyze_and_persist
    analysis = analyze
    photo.update!(
      composition_analysis: analysis,
      composition_analysis_version: VERSION,
      composition_analyzed_at: Time.current,
      composition_analysis_error: nil,
    )
    true
  rescue StandardError => e
    photo.update_columns(
      composition_analysis_error: "#{e.class}: #{e.message}".truncate(1_000),
      updated_at: Time.current,
    )
    Rails.logger.error("Composition analysis failed for Flickr photo #{photo.flickr_id}: #{e.class}: #{e.message}")
    false
  end

  def analyze
    response = http.start(ENDPOINT.host, ENDPOINT.port, use_ssl: true, open_timeout: 10, read_timeout: 90) do |client|
      client.request(request)
    end
    raise "OpenAI returned HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    parsed = JSON.parse(response.body)
    text = parsed.fetch('output').flat_map { |item| item.fetch('content', []) }
                 .find { |content| content['type'] == 'output_text' }&.fetch('text')
    analysis = validate(JSON.parse(text || raise('OpenAI response contained no structured output')))
    analysis['techniques'].each do |technique|
      technique['classification_id'] = "flickr:#{photo.flickr_id}:#{technique.fetch('key')}"
    end
    analysis.merge(
      'image_flickr_id' => photo.flickr_id,
      'analysis_version' => VERSION,
      'api_model' => parsed.fetch('model', payload[:model]),
      'api_usage' => parsed.fetch('usage', {}),
    )
  end

  private

  attr_reader :photo, :http

  def request
    Net::HTTP::Post.new(ENDPOINT).tap do |request|
      request['Authorization'] = "Bearer #{ENV.fetch('OPENAI_API_KEY')}"
      request['Content-Type'] = 'application/json'
      request.body = JSON.generate(payload)
    end
  end

  def payload
    {
      model: ENV.fetch('OPENAI_COMPOSITION_MODEL', 'gpt-5-mini'),
      store: false,
      input: [{
        role: 'user',
        content: [
          { type: 'input_text', text: prompt },
          { type: 'input_image', image_url: image_url, detail: 'high' },
        ],
      }],
      text: { format: { type: 'json_schema', name: 'photographic_composition', strict: true, schema: schema } },
    }
  end

  def image_url
    data = photo.photo_data.deep_symbolize_keys
    data.dig(:photo_large, :url) || data.dig(:photo_medium, :url) || raise('Photo has no analyzable image URL')
  end

  def prompt
    <<~PROMPT
      Act as a rigorous street-photography editor. Analyze only compositional techniques that are visibly and strongly supported in this photograph. Return zero to three techniques; returning none is better than guessing.

      Technique definitions:
      - thirds: a meaningful subject or visual anchor is deliberately placed near a thirds line or intersection.
      - leading: actual visible edges, curves, shadows, rails, roads, or gestures direct the eye toward a subject. Never infer invisible lines.
      - triangle: three distinct subjects or objects form the corners of a clearly implied, non-collinear triangle.
      - odds: exactly 3 or 5 comparable, countable subjects or objects form the compelling grouping. Do not use this merely because three salient regions exist.
      - layers: distinct foreground, middle-ground, and background planes create narrative depth.
      - space: substantial low-detail negative space isolates a subject or provides directional room.
      - spiral: visible curves or arranged subjects create a credible circulating path through the frame.
      - pattern: repeated comparable forms create rhythm, usually with a meaningful interruption or variation.
      - density: meaningful detail or repetition fills nearly the whole frame with genuinely little negative space.
      - frame: a visible doorway, window, arch, foreground shape, shadow, or architectural opening surrounds and emphasizes a subject within the photograph.
      - symmetry: clearly mirrored or centrally balanced forms across a visible axis are a primary source of the image's visual force.
      - juxtaposition: two visibly distinct subjects, objects, signs, or ideas gain meaning from their contrast, resemblance, or accidental relationship.
      - color: a specific complementary, repeated, or isolated color relationship organizes attention and is central to the composition—not merely because the photograph is colorful.
      - diagonal: one or more strong diagonal forms create energy, division, or tension across the frame. Use leading instead when the form's primary job is directing attention to a subject.

      Every classification must be unique to this exact image: name its concrete visible subjects, objects, colors, gestures, or structures. Never return generic copy that could describe another photograph. Every selected technique must also produce a useful, image-specific overlay: provide at least one point on the actual evidence, plus a subtle bounding region when it helps. If you cannot place an honest overlay, omit the technique. Coordinates use percentages from the image's top-left, from 0 to 100. For leading lines, diagonals, spirals, patterns, and layered planes, order multiple points along the visible path or boundary. For triangle use exactly 3 points; for odds use exactly 3 or 5 subject centers; for juxtaposition use the two contrasted subject centers; for symmetry use two points defining the axis. A region may be null only when the points alone clearly explain the classification. Do not select a weak technique merely to create variety.

      Photograph title: #{photo.photo_data['title'].presence || 'Untitled'}
      Photograph description: #{photo.photo_data['description'].presence || 'None'}
    PROMPT
  end

  def schema
    point = {
      type: 'object', additionalProperties: false, required: %w[x y],
      properties: { x: { type: 'number', minimum: 0, maximum: 100 }, y: { type: 'number', minimum: 0, maximum: 100 } },
    }
    region = {
      type: 'object', additionalProperties: false, required: %w[x y width height],
      properties: {
        x: { type: 'number', minimum: 0, maximum: 100 }, y: { type: 'number', minimum: 0, maximum: 100 },
        width: { type: 'number', minimum: 0, maximum: 100 }, height: { type: 'number', minimum: 0, maximum: 100 },
      },
    }
    {
      type: 'object', additionalProperties: false, required: %w[summary techniques],
      properties: {
        summary: { type: 'string', maxLength: 320 },
        techniques: {
          type: 'array', maxItems: 3,
          items: {
            type: 'object', additionalProperties: false,
            required: %w[key confidence title explanation points region],
            properties: {
              key: { type: 'string', enum: TECHNIQUES }, confidence: { type: 'number', minimum: 0, maximum: 1 },
              title: { type: 'string', maxLength: 80 }, explanation: { type: 'string', maxLength: 420 },
              points: { type: 'array', minItems: 1, maxItems: 8, items: point },
              region: { anyOf: [region, { type: 'null' }] },
            },
          },
        },
      },
    }
  end

  def validate(analysis)
    techniques = analysis.fetch('techniques')
    raise 'Model returned too many techniques' if techniques.length > 3
    raise 'Model returned an unknown technique' unless techniques.all? { |item| TECHNIQUES.include?(item['key']) }
    raise 'Model returned duplicate techniques' unless techniques.pluck('key').uniq.length == techniques.length

    explanations = techniques.pluck('explanation').map { |copy| copy.to_s.squish.downcase }
    raise 'Model returned duplicate explanations' unless explanations.uniq.length == explanations.length

    analysis
  end
end
# rubocop:enable Metrics/ClassLength
