class NotificationJob
  include Sidekiq::Job

  def perform(notification_id)
    puts "run notification_job with args: ' + #{notification_id}"
    notification = Notification.find_by(id: notification_id)
    if notification.present?
      send_user_notification(notification)
    end
  end

  private

  def send_user_notification(notification)
    puts "notifying to this channel : notification_channel_#{notification.user.id}"
    # broadcast message to the NotificationChannel check -> app/channels/notification_channel.rb
    ActionCable.server.broadcast "notification_channel_#{notification.user.id}", { notification: notification}
  end
end
