require "rails_helper"

RSpec.describe MovieImport, type: :model do
  include ActionDispatch::TestProcess::FixtureFile

  let(:valid_file) { fixture_file_upload("spec/fixtures/valid_file.csv", "text/csv") }
  let(:empty_file) { fixture_file_upload("spec/fixtures/empty_file.csv", "text/csv") }
  let(:with_missing_title) { fixture_file_upload("spec/fixtures/with_missing_title.csv", "text/csv") }
  let(:invalid_file) { fixture_file_upload("spec/fixtures/invalid_file.txt", "text/plain") }

  context "Quando o arquivo é válido" do
    it "e os dados estão corretos processa filmes e atualiza o status para completed" do
      movie_import = MovieImport.create(file_name: valid_file.original_filename, status: 1)

      expect {
        movie_import.import_movies(valid_file)
      }.to change { Movie.count }.by(131)

      expect(movie_import.status).to eq("completed")
      expect(movie_import.movies_count).to eq(131)
    end

    it "mas tem filmes sem titulo corretos processa filmes e atualiza o status para failed" do
      movie_import = MovieImport.create(file_name: with_missing_title.original_filename, status: 1)

      expect {
        movie_import.import_movies(with_missing_title)
      }.to change { Movie.count }.by(0)

      expect(movie_import.status).to eq("failed")
      expect(movie_import.movies_count).to eq(0)
    end
  end

  context "Quando o arquivo é inválido" do
    it "atualiza o status para invalid_file e retorna erro de arquivo inválido" do
      movie_import = MovieImport.create(file_name: invalid_file.original_filename, status: 1)

      movie_import.import_movies(invalid_file)

      expect(movie_import.status).to eq("invalid_file")
      expect(movie_import.error_message).to eq("Formato de arquivo inválido. Por favor, envie um arquivo CSV.")
      expect(movie_import.movies_count).to eq(0)
    end

    context "Quando o arquivo é inválido" do
      it "atualiza o status para invalid_file e retorna erro de arquivo vazio" do
        movie_import = MovieImport.create(file_name: empty_file.original_filename, status: 1)

        movie_import.import_movies(empty_file)

        expect(movie_import.status).to eq("invalid_file")
        expect(movie_import.error_message).to eq("Arquivo vazio. Por favor, insira um arquivo com dados dos filmes.")
        expect(movie_import.movies_count).to eq(0)
      end
    end
  end
end
