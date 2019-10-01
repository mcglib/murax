require 'rails_helper'

RSpec.describe "ImportLogs", type: :request do
  describe "GET /import_logs" do
    it "works! (now write some real specs)" do
      get import_logs_path
      expect(response).to have_http_status(200)
    end
  end
end
