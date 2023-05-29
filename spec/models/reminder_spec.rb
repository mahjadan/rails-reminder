# frozen_string_literal: true

require 'spec_helper'
require 'rails_helper'

RSpec.describe Reminder, :type => :model do
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:due_date) }

    it 'validates that due_date cannot be in the past' do
      past_date = DateTime.now - 1.day
      reminder = FactoryBot.build(:reminder, due_date: past_date)
      expect(reminder).to_not be_valid
      expect(reminder.errors[:due_date]).to include('can not be in the past')
    end
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:notifications).dependent(:destroy) }
  end

  describe 'scopes' do
    describe '.chronological' do
      it 'orders reminders by due_date in ascending order' do
        reminder1 = FactoryBot.create(:reminder, due_date: DateTime.now + 2.days)
        reminder2 = FactoryBot.create(:reminder, due_date: DateTime.now + 1.day)
        reminder3 = FactoryBot.create(:reminder, due_date: DateTime.now + 3.days)

        expect(Reminder.chronological).to eq([reminder2, reminder1, reminder3])
      end
    end

    describe '.after' do
      it 'returns reminders with due_date after the given date' do
        today = DateTime.now + 1.minute
        tomorrow = today + 1.day
        reminder1 = FactoryBot.create(:reminder, due_date: today)
        reminder2 = FactoryBot.create(:reminder, due_date: tomorrow)
        reminder3 = FactoryBot.create(:reminder, due_date: tomorrow + 1.day)

        expect(Reminder.after(tomorrow)).to eq([reminder3])
      end
    end

    describe '.before' do
      it 'returns reminders with due_date before the given date' do
        today = DateTime.now + 1.minute
        tomorrow = today + 1.day
        reminder1 = FactoryBot.create(:reminder, due_date: today)
        reminder2 = FactoryBot.create(:reminder, due_date: tomorrow)
        reminder3 = FactoryBot.create(:reminder, due_date: tomorrow + 1.day)

        expect(Reminder.before(tomorrow)).to eq([reminder1])
      end
    end

    describe '.non_repeatable' do
      it 'returns reminders with repeat_frequency set to "no_repeat"' do
        repeatable_reminder = FactoryBot.create(:reminder, repeat_frequency: 'weekly')
        non_repeatable_reminder = FactoryBot.create(:reminder, repeat_frequency: 'no_repeat')

        expect(Reminder.non_repeatable).to eq([non_repeatable_reminder])
      end
    end
  end

  describe 'methods' do
    describe '#repeatable?' do
      it 'returns true if the repeat_frequency is not "no_repeat"' do
        reminder = FactoryBot.build(:reminder, repeat_frequency: 'daily')
        expect(reminder.repeatable?).to eq(true)
      end

      it 'returns false if the repeat_frequency is "no_repeat"' do
        reminder = FactoryBot.build(:reminder, repeat_frequency: 'no_repeat')
        expect(reminder.repeatable?).to eq(false)
      end
    end

    describe '#non_repeatable' do
      it 'returns reminders with repeat_frequency set to "no_repeat"' do
        repeatable_reminder = FactoryBot.create(:reminder, repeat_frequency: 'weekly')
        non_repeatable_reminder = FactoryBot.create(:reminder, repeat_frequency: 'no_repeat')

        expect(Reminder.non_repeatable).to eq([non_repeatable_reminder])
      end
    end
  end
end
