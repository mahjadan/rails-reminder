require "rails_helper"

RSpec.describe ReminderJob, type: :job do
  describe "#perform" do
    let(:reminder) { FactoryBot.create(:reminder) }
    let(:notification) { FactoryBot.create(:notification) }

    before do
      allow(Reminder).to receive(:find_by).with(id: reminder.id).and_return(reminder)
    end

    context "when the reminder exists" do
      context "when the reminder has no pending notifications" do
        it "creates a new notification for the reminder" do
          expect(Notification).to receive(:new).and_return(FactoryBot.build(:notification))
          expect_any_instance_of(Notification).to receive(:save).and_return(true)
          expect(NotificationJob).to receive(:perform_at)
          ReminderJob.new.perform(reminder.id, "scheduler")
        end
      end

      context "when the reminder has pending notification" do
        let(:pending_notification) { FactoryBot.create(:notification, reminder: reminder, scheduled_at: reminder.due_date) }
        before do
          reminder.notifications << pending_notification
        end
        it "does not create a new notification if a pending notification already exists for the reminder" do
          expect(Notification).not_to receive(:new)
          ReminderJob.new.perform(reminder.id, ReminderJob::SOURCE_CREATE)
        end
      end

      context "when called with SOURCE_CREATE" do
        before do
          reminder.notifications << notification
          reminder.save
        end
        it "creates a new notification" do
          expect {
            ReminderJob.new.perform(reminder.id, ReminderJob::SOURCE_CREATE)
          }.to change(Notification, :count).by(1)
        end

        it "schedules a NotificationJob" do
          expect(NotificationJob).to receive(:perform_at).with(reminder.due_date, any_args)
          ReminderJob.new.perform(reminder.id, ReminderJob::SOURCE_CREATE)
        end

        context "when reminder has repeat frequency" do
          it "schedules a new job with due date as the reminder due date" do
            reminder.update(repeat_frequency: "daily")
            expect(ReminderJob).to receive(:perform_at).with(reminder.due_date, reminder.id, ReminderJob::SOURCE_SCHEDULER)
            ReminderJob.new.perform(reminder.id, ReminderJob::SOURCE_CREATE)
          end
        end

        it "performs the job successfully" do
          expect { ReminderJob.new.perform(reminder.id, ReminderJob::SOURCE_CREATE) }.not_to raise_error
        end
      end

      context "when reminder has No repeat frequency" do
        it "does not schedule a new job" do
          reminder.update(repeat_frequency: "no_repeat")
          expect(Reminder).to receive(:find_by).with(id: reminder.id).and_return(reminder)
          expect(ReminderJob).not_to receive(:perform_at)
          ReminderJob.new.perform(reminder.id, "scheduler")
        end
      end

      context "when called with SOURCE_SCHEDULER" do
        before do
          reminder.notifications << notification
          reminder.save
        end

        it "creates a new notification if the user has not been notified" do
          expect {
            ReminderJob.new.perform(reminder.id, ReminderJob::SOURCE_SCHEDULER)
          }.to change(Notification, :count).by(1)
        end

        context "when user already notified" do
          before do
            reminder.notifications << Notification.create(reminder: reminder, user: reminder.user, scheduled_at: reminder.due_date)
            reminder.save
          end

          it "does not create a new notification if the user has already been notified" do
            ReminderJob.new.perform(reminder.id, ReminderJob::SOURCE_SCHEDULER)
            expect(Notification).not_to receive(:new)
            expect(NotificationJob).not_to receive(:perform_at)
          end
        end

        it "schedules a NotificationJob" do
          expect(NotificationJob).to receive(:perform_at).with(reminder.due_date, any_args)
          ReminderJob.new.perform(reminder.id, ReminderJob::SOURCE_SCHEDULER)
        end

        context "when reminder has repeat frequency" do
          it "schedules a new job with calculated due date" do
            reminder.update(repeat_frequency: "daily")
            next_due_date = reminder.due_date + 1.day
            expect(ReminderJob).to receive(:perform_at).with(next_due_date, reminder.id, ReminderJob::SOURCE_SCHEDULER)
            ReminderJob.new.perform(reminder.id, ReminderJob::SOURCE_SCHEDULER)
          end

          it "updates the reminder due date with tne calculated date" do
            reminder.update(repeat_frequency: "daily")
            next_due_date = reminder.due_date + 1.day
            ReminderJob.new.perform(reminder.id, ReminderJob::SOURCE_SCHEDULER)
            expect(reminder.reload.due_date).to eq(next_due_date)
          end
        end

        it "skips the job if the reminder is reconfigured" do
          reminder.update(reconfigured: true)
          expect(reminder).not_to receive(:notifications)
          expect(ReminderJob).not_to receive(:perform_at)
          expect(NotificationJob).not_to receive(:perform_at)
          ReminderJob.new.perform(reminder.id, ReminderJob::SOURCE_SCHEDULER)
        end

        context "when reminder was reconfigured" do
          it "skips the job and resets the reconfigured flag" do
            reminder.update(reconfigured: true)
            expect(Reminder).to receive(:find_by).with(id: reminder.id).and_return(reminder)
            expect(reminder).to receive(:update_attribute).with("reconfigured", false)
            ReminderJob.new.perform(reminder.id, ReminderJob::SOURCE_SCHEDULER)
          end
        end

        it "performs the job successfully" do
          expect { ReminderJob.new.perform(reminder.id, ReminderJob::SOURCE_SCHEDULER) }.not_to raise_error
        end
      end
    end

    context "when the reminder does not exist" do
      it "skips the job" do
        expect(Reminder).to receive(:find_by).with(id: reminder.id).and_return(nil)
        expect(ReminderJob).not_to receive(:perform_at)
        ReminderJob.new.perform(reminder.id, "scheduler")
      end
    end
  end
end
