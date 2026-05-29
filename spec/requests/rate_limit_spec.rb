require "rails_helper"

RSpec.describe "Rate limiting", type: :request do
  before { Rack::Attack.cache.store.clear }

  describe "POST /api/v1/movies" do
    let(:file) { Rack::Test::UploadedFile.new("spec/fixtures/valid_file.csv", "text/csv") }

    it "throttles after the import limit is exceeded" do
      Rack::Attack::IMPORT_LIMIT.times do
        post "/api/v1/movies", params: {file: file}
        expect(response.status).not_to eq(429)
      end

      post "/api/v1/movies", params: {file: file}

      expect(response).to have_http_status(:too_many_requests)
      expect(JSON.parse(response.body)["error"]).to eq(I18n.t("messages.rate_limit.too_many_requests"))
    end
  end

  describe "GET /api/v1/movies" do
    it "throttles after the read limit is exceeded" do
      Rack::Attack::READ_LIMIT.times do
        get "/api/v1/movies"
        expect(response.status).not_to eq(429)
      end

      get "/api/v1/movies"

      expect(response).to have_http_status(:too_many_requests)
    end
  end
end
