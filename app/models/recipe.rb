class Recipe < ApplicationRecord

  has_rich_text :instructions

  belongs_to :cookbook
  belongs_to :section, optional: true
  belongs_to :parent, class_name: 'Recipe', optional: true

  has_many :cooks, dependent: :destroy
  has_many :variants, class_name: 'Recipe', foreign_key: :parent_id, dependent: :nullify

  # nil = not yet assessed
  enum :kid_status, {
    good_for_kids: 'good_for_kids',
    kid_augmentable: 'kid_augmentable',
    not_kid_friendly: 'not_kid_friendly'
  }

  scope :abc, ->{ reorder(name: :asc) }
  scope :bases_only, ->{ where(parent_id: nil) }

  def display_name
    parent ? "#{parent.name} - #{name}" : name
  end

  def favorite?
    cooks_count >= 12
  end

  def forgotten?
    return false unless last_cooked_on
    return false unless favorite?
    # Dropped because the kids won't eat it is a decision, not a lapse.
    return false if not_kid_friendly?

    days_since_last_cook = (Time.zone.today - last_cooked_on).to_i

    # A window, not a ratchet: flagged once 45+ days AND 2.5x overdue, but ages
    # out past 6x — continued non-cooking means moved on, not forgotten.
    # Cooking again resets the clock, so aged-out recipes can re-enter.
    days_since_last_cook >= 45 &&
      days_since_last_cook.between?(expected_interval * 2.5, expected_interval * 6)
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
    errors.add(:parent_id, "cannot be self") if !new_record? && parent_id == id
  end

  def parent_cannot_be_variant
    errors.add(:parent_id, "must be a base recipe") if parent&.parent_id
  end
end
