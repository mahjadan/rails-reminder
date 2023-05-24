require "rails_helper"
require "turbo/test_assertions"

RSpec.describe NotificationsController, type: :request do
  let(:headers) { {"ACCEPT" => "text/vnd.turbo-stream.html"} }
  describe "POST /notifications/:id/complete" do
    let!(:reminder) { FactoryBot.create(:reminder, repeat_frequency: "daily") }
    let!(:notification) { FactoryBot.create(:notification, reminder: reminder) }

    context "when the reminder has repeat frequency" do
      it "marks the notification as completed" do
        post complete_notification_path(notification), headers: headers

        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq Mime[:turbo_stream]
        expect(response.body).to include('<turbo-stream action="prepend" target="flash">')
        expect(response.body).to include("<turbo-stream action=\"remove\" target=\"notification_notification_#{notification.id}\">")
      end
    end

    context "when the reminder does not have repeat frequency" do
      it "destroys the reminder and the notification" do
        reminder.update(repeat_frequency: "no_repeat")
        post complete_notification_path(notification), headers: headers

        expect(response).to have_http_status(:success)
        expect(Reminder.find_by(id: reminder.id)).to be_nil
        expect(Notification.find_by(id: notification.id)).to be_nil
        expect(response.body).to include("Reminder was successfully completed.")
        expect(response.body).to include("<turbo-stream action=\"remove\" target=\"notification_notification_#{notification.id}\">")
        expect(response.body).to include("<turbo-stream action=\"remove\" target=\"reminder_1\">")
        expect(response.body).to include('<turbo-stream action="prepend" target="flash">')
      end
    end

    context "when the notification is not found" do
      it "returns a not found response" do
        non_existing_notification_id = notification.id + 1
        post complete_notification_path(non_existing_notification_id, format: :html), headers: headers

        expect(response).to have_http_status(:not_found)
        expect(response.media_type).to eq("text/html") # Verify the response format is HTML
        expect(response.body).not_to include("<turbo-stream") # Ensure Turbo Stream content is not present
      end
    end
  end

  describe "GET /notifications/:id/snooze" do
    let!(:notification) { FactoryBot.create(:notification) }

    it "displays the snooze form for a notification" do
      get snooze_notification_path(notification)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('<div class="modal-body">')
      expect(response.body).to include('<form action="/notifications/1/update_snooze" accept-charset="UTF-8" method="post">')
      expect(response.body).to include('<button name="button" type="submit" class="form-control">5 minutes</button>')
      expect(response.body).to include('<button name="button" type="submit" class="form-control">10 minutes</button>')
      expect(response.body).to include('<button name="button" type="submit" class="form-control">30 minutes</button>')
      expect(response.body).to include('<button name="button" type="submit" class="form-control">45 minutes</button>')
      expect(response.body).to include('<button name="button" type="submit" class="form-control">1 hour</button>')
    end
  end

  describe "POST /notifications/:id/update_snooze" do
    let!(:notification) { FactoryBot.create(:notification) }

    context "when successful" do
      it "updates the snooze duration for a notification" do
        minutes = 10

        expect {
          post update_snooze_notification_path(notification), params: {minutes: minutes}, headers: headers
        }.not_to change { Notification.count }
        expect(notification.reload.scheduled_at).to be_within(1.minute).of(DateTime.now + minutes.minutes)

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("text/vnd.turbo-stream.html; charset=utf-8")
        expect(response.body).to include("<turbo-stream action=\"remove\" target=\"notification_notification_#{notification.id}\">")
        expect(response.body).to include("<turbo-stream action=\"remove\" target=\"reminder_#{notification.reminder.id}\">")
        expect(response.body).to include("<turbo-stream action=\"append\" target=\"today-reminders\">")
        expect(response.body).to include("<turbo-stream action=\"prepend\" target=\"flash\">")
      end
    end
  end
end
