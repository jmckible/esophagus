class RecipesController < ApplicationController

  def index
    @recipes = Current.cookbook.recipes.abc
    fresh_when @recipes.load
  end

  def show
    @recipe = Current.cookbook.recipes.find params[:id]
    fresh_when @recipe
  end

  def edit
    @recipe = Current.cookbook.recipes.find params[:id]
  end

  def new
    @recipe = Recipe.new
  end

  def create
    @recipe = Current.cookbook.recipes.build recipe_params
    if @recipe.save
      redirect_to root_url, notice: 'Recipe created'
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    @recipe = Current.cookbook.recipes.find params[:id]
    if @recipe.update(recipe_params)
      redirect_to @recipe, notice: 'Recipe updated'
    else
      render :edit, status: :unprocessable_content
    end
  end

  protected

  def recipe_params
    permitted = params.fetch(:recipe, {}).permit(:name, :link, :instructions, :section_id, :parent_id)
    # Convert empty string to nil for association fields
    permitted[:section_id] = nil if permitted[:section_id].blank?
    permitted[:parent_id] = nil if permitted[:parent_id].blank?
    permitted
  end

end
