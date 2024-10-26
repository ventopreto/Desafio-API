require "rails_helper"
require "swagger_helper"

RSpec.describe "Movies API", type: :request do
  let!(:hereditary) { Movie.create!(title: "Hereditary", genre: "Movie", year: 2018, country: "USA", published_at: "2018-08-01", description: "Spiced liberally with black comedy, this Bollywood drama follows the lethal love life of a woman who marries numerous men – only to find them flawed.") }
  let(:valid_csv) { Rack::Test::UploadedFile.new("spec/fixtures/valid_file.csv", "text/csv") }
  let(:missing_title_csv) { Rack::Test::UploadedFile.new("spec/fixtures/with_missing_title.csv", "text/csv") }
  let(:invalid_format_file) { Rack::Test::UploadedFile.new("spec/fixtures/invalid_file.txt", "text/txt") }

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
          example "application/json", :expected_response, {
            id: "123e4567-e89b-12d3-a456-426614174000",
            title: "Terrifier",
            genre: "Terror",
            year: 2016,
            country: "Estados Unidos",
            published_at: "15 de março de 2018",
            description: "O filme segue uma noite de Halloween aterrorizante em que duas jovens encontram Art the Clown, um palhaço perturbador e mortal que as persegue e tortura de maneira implacável."
          }
          schema type: :array,
            items: {
              type: :object,
              properties: {
                id: {type: :string, format: :uuid},
                title: {type: :string},
                genre: {type: :string},
                year: {type: :integer, format: :date},
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
          example "application/json", :movie_not_found, {
            message: "Nenhum filme encontrado"
          }
          schema type: :object,
            properties: {
              message: {type: :string, description: "Nenhum filme encontrado"}
            }

          let(:"query[country_eq]") { "India" }
          run_test! do
            expect(json_response["message"]).to eq("Nenhum filme encontrado")
          end
        end
      end

      context "Quando um parâmetro inválido é passado no filtro" do
        response "400", description: "retorna a mensagem de parâmetro inválido" do
          example "application/json", :invalid_params, {
            message: "Parâmetro de busca inválido"
          }
          schema type: :object,
            properties: {
              message: {type: :string, description: "Parâmetro de busca inválido"}
            }

          let(:"query[invalid_param_eq]") { "India" }
          run_test! do |response|
            expect(json_response["error"]).to eq("Parâmetro de busca inválido")
          end
        end
      end
    end

    post "Cadastra uma lista de filmes" do
      tags "Movies"
      consumes "multipart/form-data"
      produces "application/json"
      parameter name: :file, in: :formData, type: :file, required: true, description: "recebe um arquivo CSV com os dados dos filmes e cadastra no banco"

      context "Quando um arquivo CSV válido é enviado" do
        response "201", "e sem dados faltando cria os filmes no banco e retorna uma mensagem de sucesso" do
          example "application/json", :movie_created, {
            message: "Filmes adicionados com sucesso."
          }
          schema type: :object,
            properties: {
              message: {type: :string, description: "Filmes adicionados com sucesso."}
            }

          let(:file) { valid_csv }
          run_test! do
            expect(json_response["message"]).to eq("Filmes adicionados com sucesso.")
          end
        end

        response "422", "mas o título dos filmes está faltando, retorna a mensagem de que a validação falhou" do
          example "application/json", :fail_validation, {
            message: "A validação falhou: Title não pode ficar em branco"
          }
          schema type: :object,
            properties: {
              error: {type: :string, description: "A validação falhou: Title não pode ficar em branco"}
            }

          let(:file) { missing_title_csv }
          run_test! do
            expect(json_response["error"]).to include("A validação falhou: Title não pode ficar em branco")
          end
        end
      end

      context "Quando um arquivo diferente é enviado" do
        response "422", "retorna uma mensagem de erro sobre formato inválido" do
          example "application/json", :invalid_file, {
            error: "Erro na importação. Formato de arquivo inválido. Por favor, envie um arquivo CSV."
          }
          schema type: :object,
            properties: {
              error: {type: :string, description: "Erro na importação. Formato de arquivo inválido. Por favor, envie um arquivo CSV."}
            }

          let(:file) { invalid_format_file }
          run_test! do
            expect(json_response["error"]).to eq("Erro na importação. Formato de arquivo inválido. Por favor, envie um arquivo CSV.")
          end
        end
      end
    end
  end
end
