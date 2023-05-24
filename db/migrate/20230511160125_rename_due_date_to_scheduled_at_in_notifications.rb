class RenameDueDateToScheduledAtInNotifications < ActiveRecord::Migration[7.0]
  def change
    rename_column :notifications, :due_date, :scheduled_at
  end
end
