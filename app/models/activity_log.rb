class ActivityLog < ApplicationRecord
  belongs_to :user
  belongs_to :asset

  validates :action, presence: true

  ACTIONS = %w[upload download update].freeze
end
