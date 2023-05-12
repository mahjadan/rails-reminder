class RemoveForeignKeyFromNotifications < ActiveRecord::Migration[7.0]
  def change
    remove_reference :notifications, :reminder, index: true, foreign_key: true
    add_reference :notifications, :reminder, foreign_key: true
  end
end
