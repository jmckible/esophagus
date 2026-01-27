class Recipe < ApplicationRecord

  has_rich_text :instructions

  belongs_to :cookbook
  belongs_to :section, optional: true
  belongs_to :parent, class_name: 'Recipe', optional: true

  has_many :cooks, dependent: :destroy
  has_many :variants, class_name: 'Recipe', foreign_key: :parent_id, dependent: :nullify

  scope :abc, ->{ reorder(name: :asc) }
  scope :bases_only, ->{ where(parent_id: nil) }

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

  def family_last_cooked_on
    return last_cooked_on if parent_id # variants show own date

    # Base: compute max across self + all variants
    Recipe.where(id: [id] + variant_ids).maximum(:last_cooked_on)
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
  validate :cannot_be_own_parent
  validate :parent_cannot_be_variant

  def cannot_be_own_parent
    errors.add(:parent_id, "cannot be self") if parent_id == id
  end

  def parent_cannot_be_variant
    errors.add(:parent_id, "must be a base recipe") if parent&.parent_id
  end
end
