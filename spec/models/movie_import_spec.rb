require "rails_helper"

RSpec.describe MovieImport, type: :model do
  include ActionDispatch::TestProcess::FixtureFile

  let(:valid_file) { fixture_file_upload("spec/fixtures/valid_file.csv", "text/csv") }
  let(:empty_file) { fixture_file_upload("spec/fixtures/empty_file.csv", "text/csv") }
  let(:invalid_file) { fixture_file_upload("spec/fixtures/invalid_file.txt", "text/plain") }

  it "processa filmes e atualiza o status para completed" do
    movie_import = MovieImport.create(file_name: valid_file.original_filename, status: 1)

    expect {
      movie_import.import_movies(valid_file)
    }.to change { Movie.count }.by(131)

    expect(movie_import.status).to eq("completed")
    expect(movie_import.movies_count).to eq(131)
  end

  it "falha ao tentar importar arquivo inválido" do
    movie_import = MovieImport.create(file_name: invalid_file.original_filename, status: 1)

    movie_import.import_movies(invalid_file)

    expect(movie_import.status).to eq("invalid_file")
    expect(movie_import.movies_count).to eq(0)
  end

  it "falha ao tentar importar arquivo vazio" do
    movie_import = MovieImport.create(file_name: empty_file.original_filename, status: 1)

    movie_import.import_movies(empty_file)

    expect(movie_import.status).to eq("failed")
    expect(movie_import.movies_count).to eq(0)
  end
end
