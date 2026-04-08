class Collection < ApplicationRecord
  belongs_to :library
  has_many :assets, dependent: :destroy

  validates :name, presence: true

  delegate :user, to: :library
end
