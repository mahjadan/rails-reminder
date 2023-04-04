class ReminderJob
  include Sidekiq::Job

  def perform(reminder_id)

    puts "run job with args: ' + #{reminder_id}"
    begin
      reminder = Reminder.find(reminder_id)
      if reminder.repeat_frequency != 'no_repeat'
        puts "schedualing job to #{reminder.repeat_frequency}"

        due_date = calculate_next_due_date(reminder.repeat_frequency, reminder.due_date)
        reschedual_reminder(reminder,due_date)
      end
      true
    rescue => e
      false
    end
  end

  private

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

  def reschedual_reminder(reminder, due_date)
    reminder.update(due_date: due_date)
    ReminderJob.perform_at(reminder.due_date, reminder.id)
  end
end
