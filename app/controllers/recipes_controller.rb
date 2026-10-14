class RecipesController < ApplicationController

  IndexSection = Data.define(:dom_id, :name, :hue_class, :recipes) do
    def count = recipes.sum { 1 + it.variants.size }
  end

  def index
    sections = Current.cookbook.sections.by_position.includes(recipes: :variants).to_a
    @sections = sections.each_with_index.map do |section, i|
      IndexSection.new("section-#{section.id}", section.name, Section.hue_class_for(i), section.recipes.select { it.parent_id.nil? }.sort_by(&:name))
    end

    uncategorized = Current.cookbook.recipes.where(section: nil).bases_only.includes(:variants).abc.to_a
    @sections << IndexSection.new('section-uncategorized', 'Uncategorized', Section.uncategorized_hue_class(Current.cookbook), uncategorized) if uncategorized.any?
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

  def destroy
    recipe = Current.cookbook.recipes.find params[:id]
    recipe.destroy!
    redirect_to root_url, notice: "Deleted #{recipe.display_name}", status: :see_other
  end

  protected

  def recipe_params
    permitted = params.fetch(:recipe, {}).permit(:name, :link, :instructions, :section_id, :parent_id, :kid_status, :photo, :remove_photo, :book_name, :book_page)
    # Convert empty string to nil for association fields
    permitted[:section_id] = nil if permitted[:section_id].blank?
    permitted[:parent_id] = nil if permitted[:parent_id].blank?
    permitted[:kid_status] = nil if permitted[:kid_status].blank?
    permitted[:book_page] = nil if permitted[:book_page].blank?
    permitted
  end

end
