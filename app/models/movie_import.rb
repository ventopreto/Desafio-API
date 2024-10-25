class MovieImport < ApplicationRecord
  has_many :movies, dependent: :destroy

  validates :file_name, presence: true
  validates :status, presence: true

  enum status: {failed: 0, processing: 1, completed: 2, invalid_file: 3}

  def import_movies(file)
    return update_failed_import("Formato de arquivo inválido. Por favor, envie um arquivo CSV.", 3) unless valid_csv_file?(file)
    return update_failed_import("Arquivo vazio. Por favor, insira um arquivo com dados dos filmes.", 3) unless empty_file?(file)

    begin
      movies_data = create_movies(file)
      update(status: 2, movies_count: movies_data.size) if movies_data.any?
    rescue ActiveRecord::RecordInvalid => e
      update_failed_import("Erro ao criar filmes: #{e.message}", 0)
    end
  end

  private

  def update_failed_import(message, status)
    update(status: status, movies_count: 0, error_message: message)
    false
  end

  def valid_csv_file?(file)
    file && file.content_type == "text/csv"
  end

  def empty_file?(file)
    require "csv"
    CSV.readlines(file).any?
  end

  def create_movies(file)
    require "csv"
    CSV.readlines(file).map.with_index do |row, index|
      next if index == 0
      Movie.create!(
        genre: row[1],
        title: row[2],
        country: row[5],
        published_at: row[6],
        year: row[7],
        description: row[11]
      )
    end.compact
  end
end
