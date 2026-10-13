class Cook < ApplicationRecord
  belongs_to :recipe, counter_cache: true

  after_create :update_recipe_last_cooked_on
  after_destroy :update_recipe_last_cooked_on

  def update_recipe_last_cooked_on
    recipe.update last_cooked_on: recipe.cooks.maximum(:date)
  end
end
