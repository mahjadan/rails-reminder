class Notification < ApplicationRecord
  belongs_to :reminder
  belongs_to :user

  validates :due_date, presence: true

  scope :completed, -> { where.not(completed_at: nil) }
  scope :pending, -> { where(completed_at: nil) }
  scope :overdue, -> { pending.where("due_date <= ?", DateTime.now) }

end
