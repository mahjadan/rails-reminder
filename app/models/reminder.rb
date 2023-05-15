class Reminder < ApplicationRecord
    validates :title, presence: true
    validates :due_date, presence: true
    validate :due_date_cannot_be_in_the_past
    enum :repeat_frequency, { no_repeat:0, daily: 1, weekly: 2, monthly: 3, yearly: 4}, default: 0

    belongs_to :user
    has_many :notifications, dependent: :destroy

    scope :chronological, -> { order(due_date: :asc) }
    scope :after, -> (date) { where("due_date > ?", date).chronological }
    scope :before, -> (date) { where("due_date < ?", date).chronological }

    def due_date_cannot_be_in_the_past
        if due_date.present? && due_date < DateTime.now
            errors.add(:due_date, 'can not be in the past')
        end
    end
end
