class RemindersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reminder, only: %i[update edit destroy]

  # GET /reminders or /reminders.json
  # Purpose: Fetches and displays a list of reminders and notifications for the current user.
  # URL: GET /reminders
  # Request Format: HTML
  # Parameters: None
  # Response Format: HTML
  def index
    today = Date.current
    tomorrow = today + 1.day
    reminders = current_user.reminders.after(DateTime.now)
    @today_reminders = reminders.select { |r| r.due_date.to_date == today }
    @tomorrow_reminders = reminders.select { |r| r.due_date.to_date == tomorrow }
    @upcoming_reminders = reminders.reject { |r| [today, tomorrow].include?(r.due_date.to_date) }
    @missed_reminders = current_user.reminders.non_repeatable.before(DateTime.now)
    @notifications = current_user.notifications.overdue
  end

  # GET /reminders/new
  # Purpose: Displays a form to create a new reminder.
  # Request Format: HTML
  # Parameters: None
  # Response Format: HTML
  def new
    @reminder = Reminder.new(due_date: DateTime.now + 10.minutes)
    @reminder.user = current_user
  end

  # GET /reminders/:id/edit
  # Purpose: Displays a form to edit an existing reminder.
  # Request Format: HTML
  # Parameters:
  #   - :id (required) - The ID of the reminder to be edited.
  # Response Format: HTML
  def edit; end

  # POST /reminders
  # Purpose: Creates a new reminder based on the submitted form data.
  # URL: POST /reminders
  # Request Format: HTML
  # Parameters: reminder (required)
  # - Contains the reminder attributes (title, description, due_date, repeat_frequency).
  # Response Format: Turbo Stream
  def create
    @reminder = current_user.reminders.build(reminder_params)

    respond_to do |format|
      if @reminder.save
        ReminderJob.perform_async(@reminder.id, ReminderJob::SOURCE_CREATE)
        format.turbo_stream { flash.now[:notice] = "Reminder was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reminders/:id
  # Purpose: Updates an existing reminder based on the submitted form data.
  #  - reconfigure the reminder if some changes in due_date or repeat_frequency
  #  - cancel the previously scheduled ReminderJob ( by setting reconfigured to true)
  #  - schedule a new ReminderJob 
  # URL: PATCH/PUT /reminders/:id
  # Request Format: HTML
  # Parameters:
  # - :id (required) - The ID of the reminder to be updated.
  # - reminder (required)
  #  - Contains the updated reminder attributes (title, description, due_date, repeat_frequency).
  # Response Format: Turbo Stream (if successful) or HTML (if there are errors)
  def update
    @reminder.assign_attributes(reminder_params)
    # track changes in the due_date and repeat_frequency fields.
    # mark it to cancel a previously scheduled ReminderJob
    @reminder.reconfigured = true if @reminder.due_date_changed? || @reminder.repeat_frequency_changed?
    @replace = !(@reminder.due_date_changed? || @reminder.repeat_frequency_changed?)
    respond_to do |format|
      if @reminder.save
        ReminderJob.perform_async(@reminder.id, ReminderJob::SOURCE_UPDATE)
        format.turbo_stream { flash.now[:notice] = "Reminder was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reminders/:id
  # Purpose: Deletes an existing reminder.
  # Request Format: HTML
  # Parameters:
  # - :id (required) - The ID of the reminder to be deleted.
  # Response Format: Turbo Stream (if successful) or HTML (if there are errors)
  def destroy
    respond_to do |format|
      if @reminder.destroy
        format.turbo_stream { flash.now[:notice] = "Reminder was successfully deleted." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
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
