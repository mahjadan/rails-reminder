require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:reminders) }
    it { should have_many(:notifications).through(:reminders) }
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password) }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end

  describe 'devise modules' do
    it { should validate_presence_of(:password).on(:create) }
    it { should validate_presence_of(:password).on(:update) }
    it { should validate_length_of(:password).is_at_least(6) }
    it { should validate_confirmation_of(:password) }
    it { should allow_value('test@example.com').for(:email) }
    it { should_not allow_value('test').for(:email) }
  end

  describe 'behavior' do
    let(:user) { FactoryBot.create(:user) }

    it 'can have multiple reminders' do
      reminder1 = FactoryBot.create(:reminder, user: user)
      reminder2 = FactoryBot.create(:reminder, user: user)
      expect(user.reminders).to eq([reminder1, reminder2])
    end

    it 'can have multiple notifications through reminders' do
      reminder1 = FactoryBot.create(:reminder, user: user)
      reminder2 = FactoryBot.create(:reminder, user: user)
      notification1 = FactoryBot.create(:notification, reminder: reminder1)
      notification2 = FactoryBot.create(:notification, reminder: reminder2)
      expect(user.notifications).to eq([notification1, notification2])
    end
  end
end
