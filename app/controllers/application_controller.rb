class ApplicationController < ActionController::Base
  include Authentication, TimeZone, Turbo::Redirection
end
