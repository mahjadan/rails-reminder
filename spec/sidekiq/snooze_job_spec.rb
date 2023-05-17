require "rails_helper"

RSpec.describe SnoozeJob, type: :job do
  describe "#perform" do
    let(:notification) { FactoryBot.create(:notification) }

    before do
      allow(Notification).to receive(:find_by).with(id: notification.id).and_return(notification)
    end

    context "when the notification exists" do
      it "schedules the notification job" do
        expect(NotificationJob).to receive(:perform_at).with(notification.scheduled_at, notification.id)
        SnoozeJob.new.perform(notification.id)
      end
    end

    context "when the notification does not exist" do
      it "does not schedule the notification job" do
        expect(Notification).to receive(:find_by).with(id: notification.id).and_return(nil)
        expect(NotificationJob).not_to receive(:perform_at)
        SnoozeJob.new.perform(notification.id)
      end
    end
  end
end
