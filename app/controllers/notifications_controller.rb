class NotificationsController < ApplicationController
  before_action :set_notification, only: %i[complete update_snooze snooze]

  # POST /notifications/:id/complete
  # Purpose: Marks a notification as completed and handles the associated reminder.
  # URL: POST /notifications/:id/complete
  # Request Format: turbo_stream
  # Parameters:
  #   - :id (required) - The ID of the notification to be completed.
  # Response Format: Turbo Stream (if successful) or HTML (if there are errors)
  def complete
    @reminder = @notification.reminder
    @destroy = false
    respond_to do |format|
      if @reminder.repeat_frequency != "no_repeat"
        # marke this notification as completed, because the reminder has frequency
        if @notification.update_attribute("completed_at", DateTime.now)
          # we need to delete the notification from the div only
          format.turbo_stream { flash.now[:notice] = "Reminder was successfully completed." }
        else
          format.json { render json: {message: "Reminder was successfully completed."}, status: :unprocessable_entity }
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

  # GET /notifications/:id/snooze
  # Purpose: Displays the snooze form for a notification.
  # URL: GET /notifications/:id/snooze
  # Request Format: HTML
  # Parameters:
  #   - :id (required) - The ID of the notification for which to display the snooze form.
  # Response Format: HTML
  def snooze
  end

  # POST /notifications/:id/update_snooze
  # Purpose: To updates the snooze duration for a notification.
  # URL: POST /notifications/:id/update_snooze
  # Request Format: HTML
  # Parameters:
  #   - :id (required) - The ID of the notification to be snoozed.
  #   - :minutes (required) - The new snooze duration in minutes.
  # Response Format: Turbo Stream (if successful) or HTML (if there are errors)
  def update_snooze
    @reminder = @notification.reminder

    respond_to do |format|
      if @reminder.update(due_date: new_schedule_date, reconfigured: true)
        @notification.update(scheduled_at: new_schedule_date)
        SnoozeJob.perform_async(@notification.id)
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
    @notification = Notification.find_by(id: params[:id])
    render_not_found if @notification.nil?
  end

  def render_not_found
    respond_to do |format|
      format.html { render file: "#{Rails.public_path}/404.html", status: :not_found, layout: false }
      format.json { render json: {error: "Notification not found"}, status: :not_found }
    end
  end
end
