require 'net/http'

# Proxies optional observability providers without exposing their credentials.
class Api::V1::OperationsController < ApiController
  def index
    render json: { circleci: circleci_insights, new_relic: new_relic_insights }
  end

  private

  def circleci_insights
    token = ENV.fetch('CIRCLECI_TOKEN', nil)
    return disconnected('CIRCLECI_TOKEN is not configured') if token.blank?

    uri = URI('https://circleci.com/api/v2/insights/gh/Lordnibbler/railsblog/workflows/build_test_deploy')
    uri.query = URI.encode_www_form(branch: ENV.fetch('CIRCLECI_BRANCH', 'master'))
    payload = request_json(uri, { 'Circle-Token' => token })
    runs = Array(payload['items']).first(12).map do |run|
      {
        id: run['id'], duration: run['duration'], status: run['status'],
        created_at: run['created_at'], stopped_at: run['stopped_at'],
        branch: run['branch'], credits_used: run['credits_used'],
      }
    end
    { connected: true, runs: runs }
  rescue StandardError => e
    unavailable(e)
  end

  def new_relic_insights
    api_key = ENV.fetch('NEW_RELIC_USER_API_KEY', nil)
    account_id = ENV.fetch('NEW_RELIC_ACCOUNT_ID', nil)
    return disconnected('NerdGraph credentials are not configured') if api_key.blank? || account_id.blank?

    app_name = ENV.fetch('NEW_RELIC_APP_NAME', 'benradler.com').gsub("'", "''")
    nrql = <<~NRQL.squish
      SELECT average(duration) * 1000 AS response_ms,
        percentile(duration, 95) * 1000 AS p95_ms,
        rate(count(*), 1 minute) AS rpm,
        percentage(count(*), WHERE error IS true) AS error_rate
      FROM Transaction WHERE appName = '#{app_name}' SINCE 30 minutes ago
    NRQL
    query = 'query($account: Int!, $nrql: Nrql!) { actor { account(id: $account) { nrql(query: $nrql) { results } } } }'
    payload = request_json(URI('https://api.newrelic.com/graphql'), { 'API-Key' => api_key },
                           { query: query, variables: { account: account_id.to_i, nrql: nrql } })
    errors = payload['errors']
    raise errors.pluck('message').join(', ') if errors.present?

    metrics = payload.dig('data', 'actor', 'account', 'nrql', 'results')&.first || {}
    { connected: true, metrics: metrics }
  rescue StandardError => e
    unavailable(e)
  end

  def request_json(uri, headers, body = nil)
    request = body ? Net::HTTP::Post.new(uri) : Net::HTTP::Get.new(uri)
    headers.each { |key, value| request[key] = value }
    if body
      request['Content-Type'] = 'application/json'
      request.body = body.to_json
    end
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 2, read_timeout: 4) { |http| http.request(request) }
    raise "Provider returned #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  end

  def disconnected(reason)
    { connected: false, state: 'not_configured', reason: reason }
  end

  def unavailable(error)
    Rails.logger.info("Operations telemetry unavailable: #{error.class}: #{error.message}")
    { connected: false, state: 'unavailable', reason: 'Provider data is temporarily unavailable' }
  end
end
