class Notification < ApplicationRecord
  belongs_to :reminder
  belongs_to :user

  validates :scheduled_at, presence: true

  scope :completed, -> { where.not(completed_at: nil) }
  scope :pending, -> { where(completed_at: nil) }
  scope :overdue, -> { pending.where("scheduled_at <= ?", DateTime.now) }
  scope :upcoming, -> { pending.where("scheduled_at > ?", DateTime.now) }
end
