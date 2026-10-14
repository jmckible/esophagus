# A printed cookbook that recipes point to, as opposed to a link
class Book < ApplicationRecord
  belongs_to :cookbook
  has_many :recipes, dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :cookbook_id }

  scope :abc, ->{ order(:name) }
end
