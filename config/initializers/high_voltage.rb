HighVoltage.configure do |config|
  config.route_drawer = HighVoltage::RouteDrawers::Root

  # use a custom PagesController
  config.routes = false
end