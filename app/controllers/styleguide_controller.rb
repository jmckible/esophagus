class StyleguideController < ApplicationController

  def show
    recipes = Current.cookbook.recipes.bases_only.includes(:variants).with_thumbs.to_a
    @samples = [
      recipes.find { it.favorite? && it.variants.any? },
      recipes.find { !it.favorite? && it.link.present? },
      recipes.find { it.photo.attached? }
    ].compact
  end

end
