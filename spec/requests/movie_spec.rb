require "rails_helper"

RSpec.describe "Movies API", type: :request do
  include ActionDispatch::TestProcess::FixtureFile
  let(:valid_csv) { fixture_file_upload("spec/fixtures/netflix_titles.csv", "text/csv") }
  let(:invalid_csv) { fixture_file_upload("spec/fixtures/invalid_movies.txt", "text/txt") }

  describe "POST /api/v1/movie" do
    context "Quando um arquivo csv valido é enviado" do
      it "cria os filmes do banco e retorna uma mensagem de sucesso" do
        post "/api/v1/movie", params: {file: valid_csv}

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["message"]).to match(/Filmes adicionados com sucesso/)
        expect(Movie.count).to be > 0
      end
    end

    context "Quando um arquivo diferente é enviado" do
      it "retorna uma mensagem de erro sobre formato inválido" do
        post "/api/v1/movie", params: {file: invalid_csv}

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Formato de arquivo inválido. Por favor, envie um arquivo CSV.")
      end
    end

    context "Quando nenhum arquivo é enviado" do
      it "retorna uma mensagem de erro sobre arquivo não enviado" do
        post "/api/v1/movie", params: {}

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Nenhum arquivo foi enviado. Por favor, envie um arquivo CSV.")
      end
    end
  end
end
