class SessionsController < ApplicationController
  skip_before_action :authenticate

  def new
  end

  def create
    if user = User.find_by(email: params[:email])&.authenticate(params[:password])
      cookies.encrypted[:user_id] = { value: user.id, expires: 1.year.from_now }
      redirect_to root_url
    else
      redirect_to login_url, alert: 'Invalid credentials'
    end
  end

end
