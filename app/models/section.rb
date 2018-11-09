class Section < ApplicationRecord
  belongs_to :cookbook

  has_many :recipes, dependent: :nullify

  scope :by_position, ->{ reorder(position: :asc) }

  validates :name, presence: true
  validates :position, presence: true, numericality: { only_integer: true }
end
