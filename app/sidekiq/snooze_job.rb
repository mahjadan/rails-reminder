class SnoozeJob
  include Sidekiq::Job

  def perform(reminder_id, scheduled_at_str)

    puts "run snooze_job with args:  #{reminder_id}, #{scheduled_at_str}"
    reminder = Reminder.find_by(id: reminder_id)
    if reminder.present?
      # create a notification with scheduled_at passed in to snooze the notification only not the reminder
      scheduled_at = scheduled_at_str.nil? ? reminder.due_date : DateTime.parse(scheduled_at_str)
      notification = Notification.new(reminder: reminder, user: reminder.user, scheduled_at: scheduled_at)
      if notification.save
        puts "sending reminder notification id: #{notification.id}"
        NotificationJob.perform_at(notification.scheduled_at, notification.id)
      end
    end
  end
end
