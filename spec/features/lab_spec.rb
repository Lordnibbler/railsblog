require 'features_helper'

describe '/lab' do
  it 'presents the Creative Engineering Lab and its first experiment' do
    visit lab_path

    expect(page).to have_title('Creative Engineering Lab - Ben Radler')
    expect(page).to have_css('.lab-page')
    expect(page).to have_content(/Ideas you can\s*step inside\./)
    expect(page).to have_css('[data-rides-simulation]')
    expect(page).to have_css('canvas[data-rides-canvas]')
    expect(page).to have_css('[data-rides-tiles]')
    expect(page).to have_link('OpenStreetMap')
    expect(page).to have_link('CARTO')
    expect(page).to have_css('[data-rides-preset]', count: 3)
    expect(page).to have_button('Intentional overload')
    expect(page).to have_button('Stop test', disabled: true)
    expect(page).to have_css('[data-service-load]')
    expect(page).to have_css('[data-rides-metric="cancellations"]')
    expect(page).to have_css('.service-load-row[data-service-key]', count: 8)
    expect(page).to have_css('.service-load-row[data-service-key="cancels"]')
    expect(page).to have_css('[data-composition-studio]')
    expect(page).to have_content('Guided analysis')
    expect(page).to have_no_content('Recompose')
    expect(page).to have_no_content('Trace the eye')
    expect(page).to have_css('[data-technique]', count: 24)
    expect(page).to have_css('[data-technique="perspective"]')
    expect(page).to have_css('[data-technique="motion_blur"]')
    expect(page).to have_css('[data-technique="low_high_angle"]')
    expect(page).to have_css('[data-composition-select]', maximum: 12)
    expect(page).to have_css('[data-control-room]')
    expect(page).to have_css('.control-module', count: 5)
    expect(page).to have_css('[data-perf-navigation]')
    expect(page).to have_css('[data-perf-database]')
    expect(page).to have_css('[data-circleci-runs]')
    expect(page).to have_css('[data-new-relic-state]')
    expect(page).to have_css('[data-control-clock][data-release-created-at]')
    expect(page).to have_content('Catalog delivery telemetry')
    expect(page).to have_css('[data-pipeline-sync-age][data-last-sync]')
    expect(page).to have_css('.pipeline-flow li', count: 5)
    expect(page).to have_css('.pipeline-health > div', count: 2)
    expect(page).to have_no_content('Signal Garden')
    expect(page).to have_no_content('Element Fall')
    expect(page).to have_no_content('Life, Iterated')
    expect(page.body.index('Composition Studio')).to be < page.body.index('Simulated City')
    expect(page.body.index('Simulated City')).to be < page.body.index('Site Control Room')
  end

  it 'links to the lab from the desktop and mobile navigation' do
    visit root_path

    expect(page).to have_css("a[href='#{lab_path}']", text: /^lab$/i, count: 2, visible: :all)
  end

  it 'renders the simulated city controls and telemetry contract' do
    visit lab_path

    expect(page).to have_button('Run load test')
    expect(page).to have_button('Stop test', disabled: true)
    expect(page).to have_css('[data-rides-control="cancel"][min="0"][max="30"][value="8"]')
    expect(page).to have_css('[data-rides-metric="cancellations"]', text: '0')
    expect(page).to have_css('[data-rides-cancel-rate]', text: '0.0% of requests')
    expect(page.all('.service-load-row[data-service-key]').pluck(:'data-service-key')).to eq(
      %w[users pricing rides dispatch cancels payments notifications resources],
    )
    expect(page).to have_css('[data-service-key="cancels"] [data-service-rps]', text: '0')
    expect(page).to have_css('[data-service-key="resources"] [data-service-health]', text: 'Nominal')
  end
end
