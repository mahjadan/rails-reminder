require 'rails_helper'

RSpec.describe NotificationJob, type: :job do
  describe '#perform' do
    let(:notification) { FactoryBot.create(:notification) }

    context 'when notification is present' do
      it 'sends user notification' do
        allow(Notification).to receive(:find_by).with(id: notification.id).and_return(notification)
        expect(ActionCable.server).to receive(:broadcast).with("notification_channel_#{notification.user.id}", { notification: notification })
        NotificationJob.new.perform(notification.id)
      end
    end

    context 'when notification is not present' do
      it 'does not send user notification' do
        allow(Notification).to receive(:find_by).with(id: notification.id).and_return(nil)
        expect(ActionCable.server).not_to receive(:broadcast).with("notification_channel_#{notification.user.id}", { notification: notification })
        NotificationJob.new.perform(notification.id)
      end
    end
  end
end
