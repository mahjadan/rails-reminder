class CreateNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :notifications do |t|
      t.datetime :due_date
      t.references :reminder, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :completed_at

      t.timestamps
    end
  end
end
