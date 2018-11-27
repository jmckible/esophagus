class Recipe < ApplicationRecord

  has_rich_text :instructions

  belongs_to :cookbook
  belongs_to :section, optional: true

  has_many :cooks, dependent: :destroy

  scope :abc, ->{ reorder(name: :asc) }

  def favorite?
    cooks.count > (2 * cookbook.cooks_stddev)
  end

  validates :name, presence: true
end
