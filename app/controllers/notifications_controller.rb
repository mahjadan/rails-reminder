class NotificationsController < ApplicationController
  before_action :set_notification, only: %i[complete update_snooze snooze]
  def complete
    @reminder = @notification.reminder
    respond_to do |format|
      if @reminder.repeat_frequency != 'no_repeat'
        if @reminder.update_attribute('complete', true)
          format.turbo_stream { flash.now[:notice] = "Reminder was successfully completed." }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @reminder.errors, status: :unprocessable_entity }
        end
      else
        @reminder.destroy
        format.turbo_stream { flash.now[:notice] = "Reminder was successfully completed." }
      end
    end
  end

  def snooze
    # already using set_reminder
  end

  def update_snooze
    # delete the existing notification
    # let the reminderJob create a notification with the new due_date
    puts "SNOOZE POST params #{params}"
    puts "mintues: #{params[:minutes].to_i}"
    @notification = Notification.find(params[:id])
    @reminder = @notification.reminder
    @reminder.update_attribute('due_date', new_schedule_date)

    respond_to do |format|
      if @notification.delete
        ReminderJob.perform_async(@reminder.id)
        format.turbo_stream { flash.now[:notice] = "Reminder was successfully snoozed." }
      else
        format.html { render :snooze, status: :unprocessable_entity }
      end
    end
  end

  private
  def new_schedule_date
    DateTime.now + params[:minutes].to_i.minutes
  end
  def set_notification
    @notification = Notification.find(params[:id])
  end
end
