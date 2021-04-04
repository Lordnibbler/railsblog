# Base controller to be used for APIs
class ApiController < ActionController::Metal
  # Removes features for API-only controllers like cookies, flash, csrf by excluding these modules
  # from {ActionController::Base::MODULES}
  EXCLUDE_MODULES = %i[Cookies Flash RequestForgeryProtection].freeze

  ActionController::Base.without_modules(*EXCLUDE_MODULES).each do |left|
    include left
  end

  before_action :respond_with_json_by_default

  # Makes rails serve JSON by default, without a format (/api/v1/foo.json is same as /api/v1/foo)
  def respond_with_json_by_default
    request.format = :json unless params[:format]
  end
end
