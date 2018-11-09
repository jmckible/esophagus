class Cookbook < ApplicationRecord
  has_many :recipes,  dependent: :destroy
  has_many :sections, dependent: :destroy
  has_many :users,    dependent: :destroy

  has_many :cooks, through: :recipes
end
