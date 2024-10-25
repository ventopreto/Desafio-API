require "rails_helper"

RSpec.describe "Movies API", type: :request do
  include ActionDispatch::TestProcess::FixtureFile
  let(:valid_csv) { fixture_file_upload("spec/fixtures/valid_file.csv", "text/csv") }
  let(:invalid_csv) { fixture_file_upload("spec/fixtures/invalid_file.txt", "text/txt") }
  let(:movie_import) { MovieImport.new }

  describe "POST /api/v1/movies" do
    context "Quando um arquivo csv valido é enviado" do
      it "cria os filmes do banco e retorna uma mensagem de sucesso" do
        post "/api/v1/movies", params: {file: valid_csv}

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["message"]).to match(/Filmes adicionados com sucesso/)
        expect(Movie.count).to be > 0
      end
    end

    context "Quando um arquivo diferente é enviado" do
      it "retorna uma mensagem de erro sobre formato inválido" do
        post "/api/v1/movies", params: {file: invalid_csv}

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Erro na importação. Formato de arquivo inválido. Por favor, envie um arquivo CSV.")
      end
    end
  end

  describe "GET /api/v1/movies" do
    let!(:movie1) { Movie.create!(title: "3 Idiots", genre: "Movie", year: 2009, country: "India", published_at: "2019-08-01") }
    let!(:movie2) { Movie.create!(title: "Hereditary", genre: "Movie", year: 2018, country: "USA", published_at: "2018-08-01") }
    context "Quando existem filmes cadastrados" do
      it "retorna uma lista de filmes" do
        get "/api/v1/movies", params: {query: {country_eq: "India"}}

        expect(response).to have_http_status(:ok)
        expect(json_response.size).to eq(1)
        expect(json_response.first["title"]).to eq("3 Idiots")
      end
    end

    context "Quando não existem filmes cadastrados" do
      it "retorna a mensagem 'nenhum filme encontrado'" do
        get "/api/v1/movies", params: {query: {country_eq: "País das Maravilhas"}}

        expect(response).to have_http_status(:ok)
        expect(json_response["message"]).to eq(I18n.t("messages.movies.not_found"))
      end
    end

    context "Quando um Parâmetro inválido é passado no filtro" do
      it "retorna a mensagem de parâmetro inválido" do
        get "/api/v1/movies", params: {query: {invalid_param: "value"}}

        expect(response).to have_http_status(:bad_request)
        expect(json_response["error"]).to eq(I18n.t("messages.movies.invalid_query_params"))
      end
    end
  end

  def json_response
    JSON.parse(response.body)
  end
end
