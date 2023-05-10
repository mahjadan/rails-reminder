class RemindersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reminder, only: %i[show edit update destroy snooze]

  # GET /reminders or /reminders.json
  def index
    today = Date.current
    tomorrow = today + 1.day
    reminders = current_user.reminders.after(DateTime.now)
    @today_reminders = reminders.select { |r| r.due_date.to_date == today }
    @tomorrow_reminders = reminders.select { |r| r.due_date.to_date == tomorrow }
    @upcoming_reminders = reminders.reject { |r| [today, tomorrow].include?(r.due_date.to_date) }
    # create vaiable notification_reminders to list all past due reminders that are not completed of the current_user and send it to the view
    @notification_reminders = current_user.reminders.before(DateTime.now)
  end

  # GET /reminders/1 or /reminders/1.json
  def show; end

  # GET /reminders/new
  def new
    @reminder = Reminder.new(due_date: DateTime.now + 10.minutes)
    @reminder.user = current_user
  end

  # GET /reminders/1/edit
  def edit; end

  # POST /reminders or /reminders.json
  def create
    @reminder = Reminder.new(reminder_params)
    @reminder.user = current_user

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
    @replace = false

    respond_to do |format|
      if @reminder.due_date_changed? || @reminder.repeat_frequency_changed?
        # delete and recreate just like the update_snooze process
        @old_reminder = @reminder
        new_due_date = @reminder.due_date
        @reminder = Reminder.new(@old_reminder.attributes.except('id').merge(
                                   due_date: new_due_date,
                                   repeat_frequency: @reminder.repeat_frequency
                                 ))
        @reminder.user = current_user
        if @reminder.save
          @old_reminder.destroy
          ReminderJob.perform_async(@reminder.id)
          @replace = true
          format.turbo_stream { flash.now[:notice] = "Reminder was successfully updated." }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @reminder.errors, status: :unprocessable_entity }
        end
      else
        # update
        if @reminder.update(reminder_params)
          format.turbo_stream { flash.now[:notice] = "Reminder was successfully updated." }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @reminder.errors, status: :unprocessable_entity }
        end
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

  # POST /reminders/1/complete
  def complete
    @reminder = Reminder.find(params[:id])

    respond_to do |format|
      if @reminder.update_attribute('complete', true)
        format.turbo_stream { flash.now[:notice] = "Reminder was successfully completed." }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @reminder.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /reminders/1/snooze
  def snooze
    # already using set_reminder
  end

  # POST /reminders/1/update_snooze
  def update_snooze
    puts "SNOOZE POST params #{params}"
    puts "mintues: #{params[:minutes].to_i}"
    @old_reminder = Reminder.find(params[:id])
    new_due_date = DateTime.now + params[:minutes].to_i.minutes
    puts "new_due_date: #{new_due_date}"
    # check if the new_due_date is still older than now
    # or render unprocessable_entity but with
    @reminder = Reminder.new(@old_reminder.attributes.except('id').merge(due_date: new_due_date))
    respond_to do |format|
      if @reminder.save
        puts "id: #{@reminder.id}, due_date: #{@reminder.due_date}, title: #{@reminder.title}"
        @old_reminder.destroy
        ReminderJob.perform_async(@reminder.id)
        format.turbo_stream { flash.now[:notice] = "Reminder was successfully snoozed." }
        format.html { redirect_to reminders_path , notice: "Reminder was successfully created." }
        format.html { redirect_to reminder_url(@reminder), notice: "Reminder was successfully created." }
      else
        format.html { render :snooze, status: :unprocessable_entity }
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
