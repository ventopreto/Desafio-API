require "rails_helper"
require "swagger_helper"

RSpec.describe "Movies API", type: :request do
  let!(:hereditary) { Movie.create!(title: "Hereditary", genre: "Movie", year: 2018, country: "USA", published_at: "2018-08-01", description: "Spiced liberally with black comedy, this Bollywood drama follows the lethal love life of a woman who marries numerous men – only to find them flawed.") }
  let(:valid_csv) { Rack::Test::UploadedFile.new("spec/fixtures/valid_file.csv", "text/csv") }
  let(:missing_title_csv) { Rack::Test::UploadedFile.new("spec/fixtures/with_missing_title.csv", "text/csv") }
  let(:invalid_format_file) { Rack::Test::UploadedFile.new("spec/fixtures/invalid_file.txt", "text/plain") }

  path "/api/v1/movies" do
    get "Retorna uma lista de filmes cadastrados" do
      tags "Movies"
      produces "application/json"
      parameter name: :"query[title_eq]", in: :query, type: :string, description: "Filtrar por titulo", required: false
      parameter name: :"query[genre_eq]", in: :query, type: :string, description: "Filtrar por genero", required: false
      parameter name: :"query[year_eq]", in: :query, type: :string, description: "Filtrar por ano", required: false
      parameter name: :"query[country_eq]", in: :query, type: :string, description: "Filtrar por pais", required: false
      parameter name: :"query[published_at]", in: :query, type: :string, description: "Filtrar por data de publicação", required: false
      parameter name: :"query[description]", in: :query, type: :string, description: "Filtrar por descrição", required: false
      parameter name: :"query[invalid_param_eq]", in: :query, type: :string, description: "Filtro Inválido", required: false

      context "Quando há filmes correspondentes ao filtro" do
        response "200", "retorna uma lista de filmes" do
          schema type: :array,
            items: {
              type: :object,
              properties: {
                id: {type: :string, format: :uuid},
                title: {type: :string},
                genre: {type: :string},
                year: {type: :integer},
                country: {type: :string},
                published_at: {type: :string, format: :date},
                description: {type: :string}
              },
              required: ["title", "year", "genre", "published_at"]
            }

          let(:query) { {"query[country_eq]": "USA"} }
          run_test! do
            expect(response.content_type).to eq("application/json; charset=utf-8")
          end
        end
      end

      context "Quando filmes com o filtro especificado não são encontrados" do
        response "200", "retorna a mensagem de nenhum filme encontrado" do
          schema type: :object,
            properties: {
              message: {type: :string}
            }

          let(:"query[country_eq]") { "India" }
          run_test! do
            expect(json_response["message"]).to eq("Nenhum filme encontrado")
          end
        end
      end

      context "Quando um parâmetro inválido é passado no filtro" do
        response "400", description: "retorna a mensagem de parâmetro inválido" do
          schema type: :object,
            properties: {
              error: {type: :string}
            }

          let(:"query[invalid_param_eq]") { "India" }
          run_test! do
            expect(json_response["error"]).to eq("Parâmetro de busca inválido")
          end
        end
      end
    end

    post "Enfileira uma importação de filmes via CSV" do
      tags "Movies"
      consumes "multipart/form-data"
      produces "application/json"
      parameter name: :file, in: :formData, type: :file, required: true, description: "arquivo CSV com os dados dos filmes"

      context "Quando um arquivo CSV válido é enviado" do
        response "202", "enfileira o job e retorna o import_id" do
          schema type: :object,
            properties: {
              message: {type: :string},
              import_id: {type: :integer}
            }

          let(:file) { valid_csv }
          run_test! do
            expect(json_response["import_id"]).to be_present
            expect(ImportMoviesJob).to have_been_enqueued
          end
        end
      end

      context "Quando nenhum arquivo é enviado" do
        response "400", "retorna erro de arquivo faltante" do
          schema type: :object,
            properties: {
              error: {type: :string}
            }

          let(:file) { nil }
          run_test! do
            expect(json_response["error"]).to eq("Arquivo não enviado. Por favor, anexe um arquivo CSV.")
          end
        end
      end
    end
  end

  describe "POST /api/v1/movies (job execution)" do
    it "processa o CSV após executar o job e marca como completed" do
      post "/api/v1/movies", params: {file: valid_csv}
      expect(response).to have_http_status(:accepted)
      import_id = json_response["import_id"]

      expect { perform_enqueued_jobs }.to change { Movie.count }.by(131)
      expect(MovieImport.find(import_id).status).to eq("completed")
    end

    it "marca como failed quando o CSV tem registros inválidos" do
      post "/api/v1/movies", params: {file: missing_title_csv}
      import_id = json_response["import_id"]

      perform_enqueued_jobs
      import = MovieImport.find(import_id)

      expect(import.status).to eq("failed")
      expect(import.error_message).to include("Title não pode ficar em branco")
    end

    it "marca como invalid_file quando o conteúdo não é CSV" do
      post "/api/v1/movies", params: {file: invalid_format_file}
      import_id = json_response["import_id"]

      perform_enqueued_jobs
      import = MovieImport.find(import_id)

      expect(import.status).to eq("invalid_file")
      expect(import.error_message).to eq("Formato de arquivo inválido. Por favor, envie um arquivo CSV.")
    end

    it "rejeita arquivo acima do limite com 413" do
      stub_const("Api::V1::MoviesController::MAX_UPLOAD_BYTES", 100)

      post "/api/v1/movies", params: {file: valid_csv}

      expect(response).to have_http_status(:content_too_large)
      expect(json_response["error"]).to include("Arquivo muito grande")
      expect(MovieImport.count).to eq(0)
    end
  end

  path "/api/v1/movie_imports/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "ID da importação"

    get "Retorna o status de uma importação" do
      tags "Movie Imports"
      produces "application/json"

      context "Quando a importação existe" do
        response "200", "retorna o registro" do
          schema type: :object,
            properties: {
              id: {type: :integer},
              file_name: {type: :string},
              status: {type: :string},
              movies_count: {type: :integer, nullable: true},
              error_message: {type: :string, nullable: true}
            }

          let(:import) { MovieImport.create!(file_name: "valid_file.csv", status: :processing) }
          let(:id) { import.id }
          run_test! do
            expect(json_response["status"]).to eq("processing")
            expect(json_response["file_name"]).to eq("valid_file.csv")
          end
        end
      end

      context "Quando a importação não existe" do
        response "404", "retorna mensagem de não encontrada" do
          schema type: :object,
            properties: {
              error: {type: :string}
            }

          let(:id) { 0 }
          run_test! do
            expect(json_response["error"]).to eq("Importação não encontrada.")
          end
        end
      end
    end
  end
end
