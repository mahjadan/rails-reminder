class RemindersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reminder, only: %i[ show edit update destroy snooze ]

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
  def show
  end

  # GET /reminders/new
  def new
    @reminder = Reminder.new(due_date: DateTime.now + 10.minutes )
    @reminder.user = current_user
  end

  # GET /reminders/1/edit
  def edit
  end

  # POST /reminders or /reminders.json
  def create
    @reminder = Reminder.new(reminder_params)
    @reminder.user = current_user

    respond_to do |format|
      if @reminder.save
        ReminderJob.perform_async(@reminder.id)
        @reminder.due_date.to_date == Date.today ? "today-reminders" : "tomorrow-reminders"
        if @reminder.due_date.to_date == Date.today
          @target = "today-reminders"
        elsif @reminder.due_date.to_date == Date.tomorrow
          @target = "tomorrow-reminders"
        else
          @target = "upcoming-reminders"
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
    if @reminder.due_date_changed? || @reminder.repeat_frequency_changed?
      # delete and recreate just like the update_snooze process 

      
      puts "delte the createeeeeeeeee"
    else
      # update
      puts "updatingggggggggggggggg"
    end
    puts "update PARAMS: #{reminder_params}"
    puts "title changed: #{@reminder.title_changed?}"
    puts "title changed: #{@reminder.title_change}"
    respond_to do |format|
      if @reminder.update(reminder_params)
        format.turbo_stream

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
      format.html { redirect_to reminders_url, notice: "Reminder was successfully destroyed." }
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
          helpers.dom_id(@reminder,:notification)# here only replace the reminder no the whole list
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
    old_reminder = Reminder.find(params[:id])
    new_due_date = DateTime.now + params[:minutes].to_i.minutes
    puts "new_due_date: #{new_due_date}"
    # check if the new_due_date is still older than now
    # or render unprocessable_entity but with 
    @reminder = Reminder.new(old_reminder.attributes.except("id").merge(due_date: new_due_date))
    respond_to do |format|
      if @reminder.save
        puts "id: #{@reminder.id}, due_date: #{@reminder.due_date}, title: #{@reminder.title}"
        old_reminder.destroy
        ReminderJob.perform_async(@reminder.id)
        # format.html { redirect_to reminder_url(@reminder), notice: "Reminder was successfully created." }
        # format.html { redirect_to reminders_path , notice: "Reminder was successfully created." }
        format.turbo_stream do
          # replace the new reminder in the reminders list
          # render turbo_stream: []
          render turbo_stream: [
            # turbo_stream.prepend('reminders', partial: "reminders/reminder",locals: {reminder: @reminder}),
            # remove the old reminder from notification
            # turbo_stream.remove(old_reminder),
            turbo_stream.remove(helpers.dom_id(old_reminder,:notification)),
            turbo_stream.replace(old_reminder, partial: "reminders/reminder",locals: {reminder: @reminder})
          ]
        end
      else
        format.html { render :snooze, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_reminder
      begin
        @reminder = Reminder.find(params[:id])
      rescue => e
        redirect_to reminders_path
      end
    end

    # Only allow a list of trusted parameters through.
    def reminder_params
      params.require(:reminder).permit(:title, :description, :due_date, :repeat_frequency)
    end
end
