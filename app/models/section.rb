class Section < ApplicationRecord
  belongs_to :cookbook

  has_many :recipes, dependent: :nullify

  scope :by_position, ->{ reorder(position: :asc) }

  validates :name, presence: true
  validates :position, presence: true, numericality: { only_integer: true }

  # Number of distinct section colors in CSS
  COLOR_COUNT = 13

  # Returns the CSS color class for badges, or nil if first section
  def color_class
    index = color_index_for_section
    index ? "section-color-#{index}" : nil
  end

  # Returns the CSS color class for section links
  def link_color_class
    index = color_index_for_section
    index ? "section-link-#{index}" : nil
  end

  private

  def color_index_for_section
    sections = cookbook.sections.by_position.to_a
    section_index = sections.index(self)

    return nil if section_index == 0  # First section has no color

    (section_index - 1) % COLOR_COUNT
  end
end
