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
    reminder_model = Reminder.new(data['reminder'])
    puts "create reminder_model : #{reminder_model}"

    Turbo::StreamsChannel.broadcast_prepend_to(
      "reminders-stream",
      partial: "reminders/notification",
      target: "notification_div",
      locals: {
        reminder: reminder_model
      }
    )
  end
end
