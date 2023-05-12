class AddReminderModifiedToReminders < ActiveRecord::Migration[7.0]
  def change
    add_column :reminders, :reminder_modified, :boolean, null: false, default: false
  end
end
