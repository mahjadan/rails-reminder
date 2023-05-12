class ChangeReminderModifiedToReconfiguredToReminders < ActiveRecord::Migration[7.0]
  def change
    rename_column :reminders, :reminder_modified, :reconfigured
  end
end
