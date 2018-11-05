class Recipe < ApplicationRecord

  has_rich_text :instructions

  belongs_to :cookbook

  has_many :cooks, dependent: :destroy

  scope :abc, ->{ reorder(name: :asc) }

  validates :name, presence: true
end
