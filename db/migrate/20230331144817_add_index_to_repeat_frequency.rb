class AddIndexToRepeatFrequency < ActiveRecord::Migration[7.0]
  def change
    add_index :reminders, :repeat_frequency
  end
end
