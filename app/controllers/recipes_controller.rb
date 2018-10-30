class RecipesController < ApplicationController

  def index
    @recipes = Current.cookbook.recipes.abc
  end

  def show
    @recipe = Current.cookbook.recipes.find params[:id]
  end

  def edit
    @recipe = Current.cookbook.recipes.find params[:id]
  end

  def new
    @recipe = Recipe.new
  end

  def create
    @recipe = Current.cookbook.recipes.build recipe_params
    @recipe.save!
    redirect_to root_url
  rescue ActiveRecord::RecordInvalid
    render :new
  end

  def update
    @recipe = Current.cookbook.recipes.find params[:id]
    @recipe.update! recipe_params
    redirect_to @recipe
  rescue ActiveRecord::RecordInvalid
    render :edit
  end

  protected

  def recipe_params
    params.fetch(:recipe, {}).permit(:name, :link, :notes)
  end

end
