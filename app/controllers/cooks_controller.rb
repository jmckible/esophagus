class CooksController < ApplicationController

  def create
    @recipe = Current.cookbook.recipes.find params[:recipe_id]
    @cook = @recipe.cooks.build params.fetch(:cook, {}).permit(:date)
    @cook.save
    @recipe.reload
  end

  def destroy
    @cook = Current.cookbook.cooks.find params[:id]
    @recipe = @cook.recipe
    @cook.destroy
    @recipe.reload
  end

end
