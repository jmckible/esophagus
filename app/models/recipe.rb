class Recipe < ApplicationRecord

  has_rich_text :instructions

  # 4:3 to match the header slot, at twice its 440px width
  has_one_attached :photo do |attachable|
    attachable.variant :header, resize_to_fill: [880, 660], format: :webp, saver: { quality: 80 }
  end

  attr_accessor :remove_photo

  belongs_to :cookbook
  belongs_to :section, optional: true
  belongs_to :parent, class_name: 'Recipe', optional: true
  belongs_to :book, optional: true

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

  def book_name
    defined?(@book_name) ? @book_name : book&.name
  end

  # Typed in the form. Resolved on validation, since building through
  # cookbook.recipes assigns attributes before the cookbook.
  def book_name=(name)
    @book_name = name.to_s.squish
  end

  # "Dinner, p. 77"
  def book_source
    [book_name, ("p. #{book_page}" if book_page)].compact.join(', ') if book
  end

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

  # A base's own cooks plus its variants'; a variant just its own.
  def family_cooks
    Cook.where(recipe_id: [id] + variant_ids).order(:date)
  end

  # Median days between cooks. Unlike expected_interval this ignores the time
  # before the first cook, and one long lapse doesn't drag it out.
  def typical_interval
    dates = family_cooks.distinct.pluck(:date)
    return if dates.size < 3

    gaps = dates.each_cons(2).map { |a, b| (b - a).to_i }.sort
    gaps[gaps.size / 2]
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
  validate :photo_is_an_image
  validate :book_in_same_cookbook

  before_validation if: -> { defined?(@book_name) } do
    self.book = @book_name.presence && cookbook.books.find_or_initialize_by(name: @book_name)
  end

  # A new upload in the same save wins over the remove box
  after_save do
    photo.purge_later if ActiveModel::Type::Boolean.new.cast(remove_photo) && !attachment_changes.key?('photo')
  end

  def cannot_be_own_parent
    errors.add(:parent_id, "cannot be self") if !new_record? && parent_id == id
  end

  def parent_cannot_be_variant
    errors.add(:parent_id, "must be a base recipe") if parent&.parent_id
  end

  def book_in_same_cookbook
    errors.add(:book, "must be in this cookbook") if book && book.cookbook_id != cookbook_id
  end

  def photo_is_an_image
    errors.add(:photo, "must be an image") if photo.attached? && !photo.content_type.to_s.start_with?('image/')
  end
end
