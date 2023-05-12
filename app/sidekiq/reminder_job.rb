class ReminderJob
  include Sidekiq::Job

  SOURCE_CREATE = 'create'.freeze
  SOURCE_UPDATE = 'update'.freeze
  SOURCE_SCHEDULER = 'scheduler'.freeze
  # @param [String] reminder_id
  # @param [Boolean] skip_check - if true then skip the check for reconfigured flag
  # @return [Boolean] true if the job is scheduled
  def perform(reminder_id, source, skip_check=false)

    puts "run reminder_job with args: ' + #{reminder_id}"
    reminder = Reminder.find_by(id: reminder_id)

    if reminder.present?
      # if the reminder has been reconfigured then skip the job and reset the flag
      if !skip_check &&  reminder.reconfigured
        puts "skipping reminder job for reminder id: #{reminder.id}"
        reminder.update(reconfigured: false)
        return
      end

      # don't create notification if user has already been notified
      notification = reminder.notification.pending.find_by(scheduled_at: reminder.due_date)
      puts "find by result #{notification}"
      if notification.nil?
        notification = Notification.new(reminder: reminder, user: reminder.user, scheduled_at: reminder.due_date)
        if notification.save
          puts "sending reminder notification id: #{notification.id}"
          NotificationJob.perform_at(notification.scheduled_at, notification.id)
        end
      end

      if reminder.repeat_frequency != 'no_repeat'
        puts "******schedualing job to #{reminder.repeat_frequency}"
        # due_date = calculate_next_due_date(reminder.repeat_frequency, reminder.due_date)
        due_date = calculate_due_date(reminder, source)
        reminder.update(due_date: due_date)
        reschedual_reminder(reminder.id, due_date)
      end
    end
  end

  private
  # returns the next due date for the reminder if the source is triggered by the scheduler
  # otherwise returns the reminder due date
  def calculate_due_date(reminder, source)
    if source == SOURCE_SCHEDULER
      calculate_next_due_date(reminder.repeat_frequency, reminder.due_date)
    else
      reminder.due_date
    end
  end

  def calculate_next_due_date(repeat,due_date)
    case repeat
    when 'daily'
      due_date + 1.day
    when 'weekly'
      due_date + 1.week
    when 'monthly'
      due_date + 1.month
    when 'yearly'
      due_date + 1.year
    else
      due_date
    end
  end

  def reschedual_reminder(reminder_id,due_date)
    ReminderJob.perform_at(due_date, reminder_id, SOURCE_SCHEDULER)
  end
end
