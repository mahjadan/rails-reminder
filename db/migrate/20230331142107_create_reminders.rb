class CreateReminders < ActiveRecord::Migration[7.0]
  def change
    create_table :reminders do |t|
      t.string :title
      t.text :description
      t.datetime :due_date
      t.integer :repeat_frequency

      t.timestamps
    end
  end
end
