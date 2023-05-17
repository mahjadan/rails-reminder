require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#flash_class" do
    it 'returns the Bootstrap alert class for "success" level' do
      expect(flash_class("success")).to eq("alert-success")
    end

    it 'returns the Bootstrap alert class for "error" level' do
      expect(flash_class("error")).to eq("alert-danger")
    end

    it 'returns the Bootstrap alert class for "notice" level' do
      expect(flash_class("notice")).to eq("alert-info")
    end

    it 'returns the Bootstrap alert class for "alert" level' do
      expect(flash_class("alert")).to eq("alert-danger")
    end

    it 'returns the Bootstrap alert class for "warn" level' do
      expect(flash_class("warn")).to eq("alert-warning")
    end

    it "returns nil for an invalid level" do
      expect(flash_class("invalid")).to be_nil
    end
  end
end
