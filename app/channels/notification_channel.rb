class NotificationChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    stream_from "notification_channel_#{params[:user_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
  # this method can be called from notification_channel.js (front end js)
  def rb_notify(data)
    reminder = Reminder.new(data['reminder'])
    puts data['reminder']
    puts "rb_notify usre_id: #{data['reminder']['user_id']}"
    puts "rb_notify reminders-stream-#{data['reminder']['user_id']}"
    # broadcast to a stream that is especific to the user
    Turbo::StreamsChannel.broadcast_prepend_to(
      "reminders-stream-#{data['reminder']['user_id']}",
      partial: "reminders/notification",
      target: "notifications_div",
      locals: {
        reminder: reminder
      }
    )
  end
end
