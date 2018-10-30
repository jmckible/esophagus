class Recipe < ApplicationRecord
  belongs_to :cookbook

  scope :abc, ->{ reorder(name: :asc) }

  validates :name, presence: true
end
