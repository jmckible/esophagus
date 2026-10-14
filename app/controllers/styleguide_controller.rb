class StyleguideController < ApplicationController

  def show
    recipes = Current.cookbook.recipes.bases_only.includes(:variants).to_a
    @samples = [
      recipes.find { it.favorite? && it.variants.any? },
      recipes.find { !it.favorite? && it.link.present? }
    ].compact
  end

end
