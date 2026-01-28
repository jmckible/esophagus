class ApplicationController < ActionController::Base
  include Authentication, TimeZone
end
