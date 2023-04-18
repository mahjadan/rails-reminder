class AddCompleteToReminders < ActiveRecord::Migration[7.0]
  def change
    add_column :reminders, :complete, :boolean
  end
end
