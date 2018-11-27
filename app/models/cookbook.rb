class Cookbook < ApplicationRecord
  has_many :recipes,  dependent: :destroy
  has_many :sections, dependent: :destroy
  has_many :users,    dependent: :destroy

  has_many :cooks, through: :recipes

  def cooks_stddev
    @cooks_stddev ||= recipes.pluck(:cooks_count).standard_deviation
  end
end
