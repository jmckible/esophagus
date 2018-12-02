module TimeZone
  extend ActiveSupport::Concern

  included do
    before_action :set_time_zone
  end

  private

  def set_time_zone
    Time.zone = (cookies[:time_zone].presence || 'UTC').delete('"')
  end

end
