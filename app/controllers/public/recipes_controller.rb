class Public::RecipesController < ApplicationController
  skip_before_action :authenticate

  def show
    @recipe = Recipe.find params[:id]
  end

end
