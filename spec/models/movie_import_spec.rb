require "rails_helper"

RSpec.describe MovieImport, type: :model do
  let(:valid_path) { Rails.root.join("spec/fixtures/valid_file.csv").to_s }
  let(:empty_path) { Rails.root.join("spec/fixtures/empty_file.csv").to_s }
  let(:missing_title_path) { Rails.root.join("spec/fixtures/with_missing_title.csv").to_s }
  let(:invalid_path) { Rails.root.join("spec/fixtures/invalid_file.txt").to_s }
  let(:malformed_path) { Rails.root.join("spec/fixtures/malformed.csv").to_s }

  context "Quando o arquivo é válido" do
    it "e os dados estão corretos processa filmes e atualiza o status para completed" do
      movie_import = MovieImport.create!(file_name: "valid_file.csv", status: :processing)

      expect {
        movie_import.import_movies(valid_path, "text/csv")
      }.to change { Movie.count }.by(131)

      expect(movie_import.status).to eq("completed")
      expect(movie_import.movies_count).to eq(131)
    end

    it "mas tem filmes sem titulo processa filmes e atualiza o status para failed" do
      movie_import = MovieImport.create!(file_name: "with_missing_title.csv", status: :processing)
      error_message = "Erro ao criar filmes: A validação falhou: Title não pode ficar em branco"

      expect {
        movie_import.import_movies(missing_title_path, "text/csv")
      }.to change { Movie.count }.by(0)

      expect(movie_import.status).to eq("failed")
      expect(movie_import.error_message).to eq(error_message)
      expect(movie_import.movies_count).to eq(0)
    end
  end

  context "Quando o arquivo é inválido" do
    it "atualiza o status para invalid_file e retorna erro de arquivo inválido" do
      movie_import = MovieImport.create!(file_name: "invalid_file.txt", status: :processing)

      movie_import.import_movies(invalid_path, "text/plain")

      expect(movie_import.status).to eq("invalid_file")
      expect(movie_import.error_message).to eq("Formato de arquivo inválido. Por favor, envie um arquivo CSV.")
      expect(movie_import.movies_count).to eq(0)
    end

    it "atualiza o status para invalid_file e retorna erro de arquivo vazio" do
      movie_import = MovieImport.create!(file_name: "empty_file.csv", status: :processing)

      movie_import.import_movies(empty_path, "text/csv")

      expect(movie_import.status).to eq("invalid_file")
      expect(movie_import.error_message).to eq("Arquivo vazio. Por favor, insira um arquivo com dados dos filmes.")
      expect(movie_import.movies_count).to eq(0)
    end

    it "marca como invalid_file quando o CSV está mal formado" do
      movie_import = MovieImport.create!(file_name: "malformed.csv", status: :processing)

      movie_import.import_movies(malformed_path, "text/csv")

      expect(movie_import.status).to eq("invalid_file")
      expect(movie_import.error_message).to eq("CSV mal formado. Não foi possível processar o arquivo.")
      expect(movie_import.movies_count).to eq(0)
    end
  end
end
