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
        @reminder.due_date.to_date == Date.today ? 'today-reminders' : 'tomorrow-reminders'
        @target = if @reminder.due_date.to_date == Date.today
                    'today-reminders'
                  elsif @reminder.due_date.to_date == Date.tomorrow
                    'tomorrow-reminders'
                  else
                    'upcoming-reminders'
                  end
        format.turbo_stream
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
          format.turbo_stream
          format.html { redirect_to reminder_url(@reminder), notice: "Reminder was successfully created." }
          format.html { redirect_to reminders_path , notice: "Reminder was successfully created." }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @reminder.errors, status: :unprocessable_entity }
        end
      else
        # update
        if @reminder.update(reminder_params)
          format.turbo_stream
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
    puts "complete params #{params}"
    @reminder = Reminder.find(params[:id])
    puts "complete #{@reminder.id} #{@reminder.title}"
    @reminder.update(complete: true)
    # remove notification from both reminders and notifications_div
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove(
          @reminder
        ) + turbo_stream.remove(
          helpers.dom_id(@reminder, :notification) # here only replace the reminder no the whole list
        )
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
        format.turbo_stream
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
