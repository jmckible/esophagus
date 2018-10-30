class SessionsController < ApplicationController
  skip_before_action :authenticate

  def new
  end

  def create
    if user = User.find_by(email: params[:email])&.authenticate(params[:password])
      cookies.encrypted[:user_id] = user.id
      redirect_to root_url
    else
      redirect_to login_url, alert: 'Invalid credentials'
    end
  end

end
