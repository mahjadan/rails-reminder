class NotificationJob
  include Sidekiq::Job

  def perform(reminder_id)
    puts "run notification_job with args: ' + #{reminder_id}"
    reminder = Reminder.find(reminder_id)

    # check if the reminder has been updated/done 
    # for now let's send notifcation
    send_user_notification(reminder)

    true
  rescue
    false
  end

  private

  def send_user_notification(reminder)
    user = {
      id: reminder.user.id,
      email: reminder.user.email,
      username: reminder.user.email.split('@')[0]
    }
    puts "calling notify_user : #{user}"
    ActionCable.server.broadcast "notification_channel", {user:}
  end
end
