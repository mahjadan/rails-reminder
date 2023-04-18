class RemindersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reminder, only: %i[ show edit update destroy ]

  # GET /reminders or /reminders.json
  def index
    @reminders = current_user.reminders
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
    # @reminder = current_user.reminders.build(reminder_params)
    @reminder = Reminder.new(reminder_params)
    @reminder.user = current_user


    respond_to do |format|
      if @reminder.save
        ReminderJob.perform_async(@reminder.id)
        # format.html { redirect_to reminder_url(@reminder), notice: "Reminder was successfully created." }
        # format.html { redirect_to reminders_path , notice: "Reminder was successfully created." }
        # format.turbo_stream
        format.turbo_stream do
          render turbo_stream: turbo_stream.prepend('reminders', partial: "reminders/reminder",
             locals: {reminder: @reminder})
        end

        # format.json { render :show, status: :created, location: @reminder }
      else
        format.html { render :new, status: :unprocessable_entity }
        # format.json { render json: @reminder.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reminders/1 or /reminders/1.json
  def update
    respond_to do |format|
      if @reminder.update(reminder_params)
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            @reminder,# here only replace the reminder no the whole list
            partial: "reminders/reminder",
            locals: { reminder: @reminder }
          )
        end
        format.html { redirect_to reminder_url(@reminder), notice: "Reminder was successfully updated." }
        format.json { render :show, status: :ok, location: @reminder }
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

  def snooze
    puts "SNOOZE params #{params}"
    @reminder = Reminder.find(params[:id])
    puts "SNOOZE #{@reminder.id} #{@reminder.title}"
    # respond_to do |format|
    #   format.turbo_stream do
    #       render turbo_stream: turbo_stream.replace(
    #         @reminder,# here only replace the reminder no the whole list
    #         partial: "reminders/form",
    #         target: "modal-frame",
    #         locals: { reminder: @reminder }
    #       )
    #   end
    # end
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
