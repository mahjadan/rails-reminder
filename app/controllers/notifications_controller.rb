class NotificationsController < ApplicationController
  before_action :set_notification, only: %i[complete update_snooze snooze]
  def complete
    @reminder = @notification.reminder
    @destroy = false
    respond_to do |format|
      if @reminder.repeat_frequency != 'no_repeat'
        # marke this notification as completed, because the reminder has frequency
        if @notification.update_attribute('completed_at', DateTime.now)
          # we need to delete the notification from the div only
          format.turbo_stream { flash.now[:notice] = "Reminder was successfully completed." }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @reminder.errors, status: :unprocessable_entity }
        end
      else
        # reminder does not have frequency, delete the whole reminder
        @reminder.destroy
        # we need to delete the notification from the div and the reminder from the list
        @destroy = true
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

    respond_to do |format|
      if @notification.delete
        SnoozeJob.perform_async(@reminder.id, new_schedule_date.to_s)
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
