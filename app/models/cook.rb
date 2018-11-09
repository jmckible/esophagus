class Cook < ApplicationRecord
  belongs_to :recipe, counter_cache: true

  after_create :update_recipe_last_cooked_on
  def update_recipe_last_cooked_on
    recipe.update last_cooked_on: recipe.cooks.reorder(date: :desc).first.date
  end
end
