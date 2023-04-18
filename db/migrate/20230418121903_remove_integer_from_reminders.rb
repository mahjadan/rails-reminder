class RemoveIntegerFromReminders < ActiveRecord::Migration[7.0]
  def change
    remove_column :reminders, :integer, :string
  end
end
