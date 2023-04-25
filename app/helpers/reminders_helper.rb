module RemindersHelper
    # Returns the id of the div that a reminder should be put in
    # based on it's due_date.
    #
    # reminder - The reminder to find a div for
    #
    # Examples
    #
    #   target_div_id_for_reminder(reminder)
    #   # => 'today-reminders'
    #
    # Returns the string id of the div that the reminder should be added to.

    def target_div_id_for_reminder(reminder)
        return 'today-reminders' if today?(reminder)
        return 'tomorrow-reminders' if tomorrow?(reminder)
        'upcoming-reminders'
    end

    # Format the time to be a 24 hour time string
    def format_24_hour(time)
        time.strftime("%H:%M")
    end

    private
    def today?(reminder)
        Date.today == reminder.due_date.to_date
    end

    def tomorrow?(reminder)
        Date.tomorrow == reminder.due_date.to_date
    end
end
