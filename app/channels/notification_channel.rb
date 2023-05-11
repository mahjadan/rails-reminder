class NotificationChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    stream_from "notification_channel_#{params[:user_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
  # this method can be called from notification_channel.js (front-end js)
  def rb_notify(data)
    notification = Notification.new(data['notification'])
    puts data['notification'].to_json
    # broadcast to a stream that is especific to the user passing the notification instance
    Turbo::StreamsChannel.broadcast_prepend_to(
      "reminders-stream-#{data['notification']['user_id']}",
      partial: "reminders/notification",
      target: "notifications_div",
      locals: {
        notification: notification
      }
    )
  end
end
