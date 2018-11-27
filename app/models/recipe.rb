class Recipe < ApplicationRecord

  has_rich_text :instructions

  belongs_to :cookbook
  belongs_to :section, optional: true

  has_many :cooks, dependent: :destroy

  scope :abc, ->{ reorder(name: :asc) }

  def favorite?
    cooks.count > cookbook.favorite_benchmark
  end

  def forgotten?
    return false unless last_cooked_on
    last_cooked_on < cookbook.forgotten_benchmark.days.ago
  end

  validates :name, presence: true
end
