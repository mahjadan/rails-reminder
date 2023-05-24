require "rails_helper"

RSpec.describe NotificationsController, type: :controller do
  describe "POST #complete" do
    let(:notification) { instance_double(Notification) }
    let(:reminder) { instance_double(Reminder) }

    before do
      allow(Notification).to receive(:find_by).and_return(notification)
      allow(notification).to receive(:reminder).and_return(reminder)
    end

    context "when the reminder has repeat frequency" do
      before do
        allow(reminder).to receive(:repeat_frequency).and_return("daily")
        allow(notification).to receive(:update_attribute).and_return(true)
      end

      it "marks the notification as completed" do
        expect(notification).to receive(:update_attribute).with("completed_at", DateTime.now)
        post :complete, params: {id: 1}, format: :turbo_stream
        expect(response).to have_http_status(:success)
      end

      it "renders the turbo stream format" do
        post :complete, params: {id: 1}, format: :turbo_stream
        expect(response.content_type).to eq("text/vnd.turbo-stream.html; charset=utf-8")
      end

      it "sets the flash notice" do
        post :complete, params: {id: 1}, format: :turbo_stream
        expect(flash.now[:notice]).to eq("Reminder was successfully completed.")
      end

      it "does not destroy the reminder" do
        expect(reminder).not_to receive(:destroy)
        post :complete, params: {id: 1}, format: :turbo_stream
      end
    end

    context "when the reminder does not have repeat frequency" do
      before do
        allow(reminder).to receive(:repeat_frequency).and_return("no_repeat")
        allow(reminder).to receive(:destroy).and_return(true)
      end

      it "destroys the reminder" do
        expect(reminder).to receive(:destroy)
        post :complete, params: {id: 1}, format: :turbo_stream
        expect(response).to have_http_status(:success)
      end

      it "renders the turbo stream format" do
        post :complete, params: {id: 1}, format: :turbo_stream
        expect(response.content_type).to eq("text/vnd.turbo-stream.html; charset=utf-8")
      end

      it "sets the flash notice" do
        post :complete, params: {id: 1}, format: :turbo_stream
        expect(flash.now[:notice]).to eq("Reminder was successfully completed.")
      end

      it "does not update the notification" do
        expect(notification).not_to receive(:update_attribute)
        post :complete, params: {id: 1}, format: :turbo_stream
      end
    end

    context "when the notification is not found" do
      before do
        allow(Notification).to receive(:find_by).and_return(nil)
      end

      it "renders the not found template" do
        post :complete, params: {id: 1, format: :html}
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
