class NotificationsController < ApplicationController
  def complete
    notification = Notification.find(params[:id])
    @reminder = notification.reminder
    respond_to do |format|
      if @reminder.update_attribute('complete', true)
        format.turbo_stream { flash.now[:notice] = "Reminder was successfully completed." }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @reminder.errors, status: :unprocessable_entity }
      end
    end
  end
end
