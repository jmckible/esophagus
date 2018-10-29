class Cookbook < ApplicationRecord
  has_many :users, dependent: :nullify
end
