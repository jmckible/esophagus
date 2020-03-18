class Public::CookbooksController < ApplicationController
  skip_before_action :authenticate, only: :show

  def show
    @cookbook = Cookbook.find_by! param: params[:id]
  end

end
