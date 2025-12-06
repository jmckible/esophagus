class Recipe < ApplicationRecord

  has_rich_text :instructions

  belongs_to :cookbook
  belongs_to :section, optional: true

  has_many :cooks, dependent: :destroy

  scope :abc, ->{ reorder(name: :asc) }

  def favorite?
    cooks_count >= 12
  end

  def forgotten?
    return false unless last_cooked_on
    return false unless favorite?

    days_since_last_cook = (Time.zone.today - last_cooked_on).to_i

    # Must be at least 45 days AND 2.5x the expected interval
    days_since_last_cook >= 45 && days_since_last_cook > expected_interval * 2.5
  end

  private

  def expected_interval
    # Calculate expected days between cooks based on recipe's lifetime and frequency
    # Uses only cached data - no queries needed
    return Float::INFINITY if cooks_count < 2

    recipe_lifetime = (last_cooked_on - created_at.to_date).to_i.clamp(1..)
    recipe_lifetime.to_f / (cooks_count - 1)
  end

  validates :name, presence: true
end
