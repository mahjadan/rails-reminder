class RemindersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reminder, only: %i[update edit destroy]

  # GET /reminders or /reminders.json
  def index
    today = Date.current
    tomorrow = today + 1.day
    reminders = current_user.reminders.after(DateTime.now)
    @today_reminders = reminders.select { |r| r.due_date.to_date == today }
    @tomorrow_reminders = reminders.select { |r| r.due_date.to_date == tomorrow }
    @upcoming_reminders = reminders.reject { |r| [today, tomorrow].include?(r.due_date.to_date) }
    # create vaiable notification_reminders to list all past due reminders that are not completed of the current_user and send it to the view
    # @notification_reminders = current_user.reminders.before(DateTime.now)
    @notifications = current_user.notifications.overdue
  end

  # GET /reminders/new
  def new
    @reminder = Reminder.new(due_date: DateTime.now + 10.minutes)
    @reminder.user = current_user
  end

  def edit; end

  def create
    @reminder = current_user.reminders.build(reminder_params)

    respond_to do |format|
      if @reminder.save
        ReminderJob.perform_async(@reminder.id)
        format.turbo_stream { flash.now[:notice] = "Reminder was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reminders/1 or /reminders/1.json
  def update
    @reminder.assign_attributes(reminder_params)
    # track changes in the due_date and repeat_frequency fields.
    # mark it to cancel a previously scheduled ReminderJob
    @reminder.reconfigured = true if @reminder.due_date_changed? || @reminder.repeat_frequency_changed?
    @replace = !(@reminder.due_date_changed? || @reminder.repeat_frequency_changed?)
    puts "reconfigured: " + @reminder.reconfigured.to_s
    respond_to do |format|
      if @reminder.save
        ReminderJob.perform_async(@reminder.id)
        format.turbo_stream { flash.now[:notice] = "Reminder was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @reminder.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reminders/1 or /reminders/1.json
  def destroy
    @reminder.destroy

    respond_to do |format|
      format.html { redirect_to reminders_url, notice: 'Reminder was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_reminder
    @reminder = Reminder.find(params[:id])
  rescue StandardError => e
    redirect_to reminders_path
  end

  # Only allow a list of trusted parameters through.
  def reminder_params
    params.require(:reminder).permit(:title, :description, :due_date, :repeat_frequency)
  end
end
