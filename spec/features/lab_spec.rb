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
    expect(page).to have_css('[data-service-load]')
    expect(page).to have_css('.service-load-row[data-service-key]', count: 9)
    expect(page).to have_css('[data-composition-studio]')
    expect(page).to have_content('Guided analysis')
    expect(page).to have_no_content('Recompose')
    expect(page).to have_no_content('Trace the eye')
    expect(page).to have_css('[data-technique]', count: 14)
    expect(page).to have_css('[data-composition-select]', maximum: 12)
    expect(page).to have_css('[data-control-room]')
    expect(page).to have_css('.control-module', count: 5)
    expect(page).to have_css('[data-perf-navigation]')
    expect(page).to have_css('[data-perf-database]')
    expect(page).to have_css('[data-circleci-runs]')
    expect(page).to have_css('[data-new-relic-state]')
    expect(page).to have_no_content('Signal Garden')
    expect(page).to have_no_content('Element Fall')
    expect(page).to have_no_content('Life, Iterated')
    expect(page.body.index('Composition Studio')).to be < page.body.index('Site Control Room')
    expect(page.body.index('Site Control Room')).to be < page.body.index('Simulated City')
  end

  it 'links to the lab from the desktop and mobile navigation' do
    visit root_path

    expect(page).to have_css("a[href='#{lab_path}']", text: /^lab$/i, count: 2, visible: :all)
  end
end
