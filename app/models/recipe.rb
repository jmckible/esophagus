class Recipe < ApplicationRecord

  has_rich_text :instructions

  belongs_to :cookbook

  scope :abc, ->{ reorder(name: :asc) }

  validates :name, presence: true
end
