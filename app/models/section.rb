class Section < ApplicationRecord
  belongs_to :cookbook

  has_many :recipes, dependent: :nullify

  scope :by_position, ->{ reorder(position: :asc) }

  validates :name, presence: true
  validates :position, presence: true, numericality: { only_integer: true }

  # Must match the .section-hue-N classes in tokens.css
  HUE_COUNT = 12

  def self.hue_class_for(position_index)
    "section-hue-#{((position_index - 1) % HUE_COUNT) + 1}" if position_index.positive?
  end

  # Uncategorized takes the hue after the last section
  def self.uncategorized_hue_class(cookbook)
    hue_class_for(cookbook.sections.count)
  end

  # nil for the first section, which is the index's default and goes unmarked
  def hue_class
    index = cookbook.sections.by_position.ids.index(id)
    self.class.hue_class_for(index) if index
  end

end
