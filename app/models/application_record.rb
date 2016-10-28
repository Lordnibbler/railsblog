# single spot to configure app-wide model behavior
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
