class CooksController < ApplicationController

  def create
    @recipe = Current.cookbook.recipes.find params[:recipe_id]
    @cook = @recipe.cooks.build params.fetch(:cook, {}).permit(:date)
    @cook.save
    redirect_to @recipe
  end

  def destroy
    @cook = Current.cookbook.cooks.find params[:id]
    @cook.destroy
    redirect_to @cook.recipe
  end

end
