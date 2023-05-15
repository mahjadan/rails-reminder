require 'rails_helper'

RSpec.describe Notification, type: :model do
  let(:reminder) { FactoryBot.create(:reminder) }
  let(:user) { FactoryBot.create(:user) }

  describe 'validations' do
    it { should validate_presence_of(:scheduled_at) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:reminder) }
  end

  describe 'scopes' do
    let!(:completed_notification) { FactoryBot.create(:notification, completed_at: DateTime.now - 1.minute) }
    let!(:pending_notification) { FactoryBot.create(:notification, scheduled_at: DateTime.now + 1.day) }
    let!(:overdue_notification) { FactoryBot.create(:notification, scheduled_at: DateTime.now - 1.day) }

    describe '.completed' do
      it 'returns completed notifications' do
        expect(Notification.completed).to eq([completed_notification])
      end
    end

    describe '.pending' do
      it 'returns pending notifications' do
        expect(Notification.pending).to eq([pending_notification,overdue_notification])
      end
    end

    describe '.overdue' do
      it 'returns overdue notifications' do
        expect(Notification.overdue).to eq([overdue_notification])
      end
    end
  end

  describe 'behavior' do
    let(:notification) { FactoryBot.create(:notification,reminder: reminder, user: user ) }

    it 'is initially not completed' do
      expect(notification.completed_at).to be_nil
    end

    it 'is associated with the correct reminder' do
      expect(notification.reminder).to eq(reminder)
    end

    it 'is associated with the correct user' do
      expect(notification.user).to eq(user)
    end
  end
end
