module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate
  end

  private

  def authenticate
    if user = User.find_by(id: cookies.encrypted[:user_id])
      Current.user = user
    else
      redirect_to login_url
    end
  end

end
