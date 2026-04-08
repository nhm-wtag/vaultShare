class Library < ApplicationRecord
  belongs_to :user
  has_many :collections, dependent: :destroy

  enum :visibility, { restricted: 0, shared: 1 }, default: :restricted

  validates :name, presence: true

  def owned_by?(user)
    self.user == user
  end
end
