class SnoozeJob
  include Sidekiq::Job

  def perform(notification_id)
    puts "run snooze_job with args:  #{notification_id}"
    notification = Notification.find_by(id: notification_id)
    if notification.present?
      puts "scheduling reminder notification id: #{notification.id}"
      NotificationJob.perform_at(notification.scheduled_at, notification.id)
    end
  end
end
