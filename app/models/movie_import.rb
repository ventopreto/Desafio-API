class MovieImport < ApplicationRecord
  has_many :movies, dependent: :destroy

  validates :file_name, presence: true
  validates :status, presence: true

  enum status: {failed: 0, processing: 1, completed: 2, invalid_file: 3}

  def import_movies(file)
    if valid_csv_file?(file)
      movies_data = parse_csv_data(file)

      if movies_data.any?
        Movie.insert_all(movies_data)
        update(status: 2, movies_count: movies_data.size)
      else
        update(status: 0, movies_count: 0)
      end
    else
      update(status: 3, movies_count: 0,
        error_message: "Formato de arquivo inválido. Por favor, envie um arquivo CSV.")
      false
    end
  end

  private

  def valid_csv_file?(file)
    file && file.content_type == "text/csv"
  end

  def parse_csv_data(file)
    require "csv"
    CSV.readlines(file).map.with_index do |row, index|
      next if index == 0
      {
        genre: row[1],
        title: row[2],
        country: row[5],
        published_at: row[6],
        year: row[7],
        description: row[11]
      }
    end.compact
  end
end
