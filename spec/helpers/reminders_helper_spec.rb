require "rails_helper"

RSpec.describe RemindersHelper, type: :helper do
  describe "#target_div_id_for_reminder" do
    it 'returns "today-reminders" if the reminder is due today' do
      reminder = double("Reminder", due_date: DateTime.now)
      expect(target_div_id_for_reminder(reminder)).to eq("today-reminders")
    end

    it 'returns "tomorrow-reminders" if the reminder is due tomorrow' do
      reminder = double("Reminder", due_date: DateTime.now + 1.day)
      expect(target_div_id_for_reminder(reminder)).to eq("tomorrow-reminders")
    end

    it 'returns "upcoming-reminders" for any other due dates' do
      reminder = double("Reminder", due_date: DateTime.now + 2.days)
      expect(target_div_id_for_reminder(reminder)).to eq("upcoming-reminders")
    end
  end

  describe "#format_24_hour" do
    it "formats the time to a 24-hour time string" do
      time = Time.new(2023, 5, 17, 14, 30)
      expect(format_24_hour(time)).to eq("14:30")
    end
  end
end
