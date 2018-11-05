class Cookbook < ApplicationRecord
  has_many :recipes, dependent: :nullify
  has_many :users, dependent: :nullify

  has_many :cooks, through: :recipes
end
