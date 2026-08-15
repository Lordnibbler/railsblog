require 'features_helper'

describe '/lab' do
  it 'presents the Creative Engineering Lab and its first experiment' do
    visit lab_path

    expect(page).to have_title('Creative Engineering Lab - Ben Radler')
    expect(page).to have_css('.lab-page')
    expect(page).to have_content('Ideas you can step inside.')
    expect(page).to have_css('[data-signal-garden]')
    expect(page).to have_css('[data-rides-simulation]')
    expect(page).to have_css('canvas[data-rides-canvas]')
    expect(page).to have_css('[data-rides-tiles]')
    expect(page).to have_link('OpenStreetMap')
    expect(page).to have_link('CARTO')
    expect(page).to have_css('[data-rides-preset]', count: 3)
    expect(page).to have_button('Intentional overload')
    expect(page).to have_css('[data-service-load]')
    expect(page).to have_css('.service-load-row[data-service-key]', count: 9)
    expect(page).to have_css('canvas[data-lab-canvas]')
    expect(page).to have_css('input[data-lab-control]', count: 3)
    expect(page).to have_css('[data-lab-palette]', count: 3)
    expect(page).to have_css('[data-photo-constellation]')
    expect(page).to have_css('[data-constellation-axis]', count: 4)
    expect(page).to have_css('[data-photographers-eye]')
    expect(page).to have_css('[data-eye-mode]', count: 3)
    expect(page).to have_css('[data-photo-timeline]')
    expect(page).to have_css('[data-control-room]')
    expect(page).to have_css('.control-module', count: 5)
    expect(page).to have_css('[data-perf-navigation]')
    expect(page).to have_css('[data-perf-database]')
    expect(page).to have_css('[data-circleci-runs]')
    expect(page).to have_css('[data-new-relic-state]')
    expect(page).to have_css('[data-sand-game] canvas[data-sand-canvas]')
    expect(page).to have_css('[data-sand-material]', count: 4)
    expect(page).to have_css('[data-life-game] canvas[data-life-canvas]')
    expect(page).to have_css('[data-life-preset]', count: 3)
  end

  it 'links to the lab from the desktop and mobile navigation' do
    visit root_path

    expect(page).to have_css("a[href='#{lab_path}']", text: 'lab', count: 2, visible: :all)
  end
end
