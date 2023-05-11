require 'rails_helper'

RSpec.describe "Notifications", type: :request do
  describe "GET /complete" do
    it "returns http success" do
      get "/notifications/complete"
      expect(response).to have_http_status(:success)
    end
  end

end
