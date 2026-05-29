require "csv"

class MovieImport < ApplicationRecord
  has_many :movies, dependent: :destroy

  validates :file_name, presence: true
  validates :status, presence: true

  enum :status, {failed: 0, processing: 1, completed: 2, invalid_file: 3}

  def import_movies(path, content_type)
    return mark_invalid_file(I18n.t("messages.import.invalid_format")) unless valid_csv?(content_type)
    return mark_invalid_file(I18n.t("messages.import.empty_file")) if blank_csv?(path)

    process(path)
  rescue ActiveRecord::RecordInvalid => e
    update!(
      status: :failed,
      movies_count: 0,
      error_message: I18n.t("messages.import.create_error", error_message: e)
    )
    false
  end

  private

  def valid_csv?(content_type)
    content_type == "text/csv"
  end

  def blank_csv?(path)
    CSV.foreach(path, headers: true).first.nil?
  end

  def process(path)
    count = 0
    Movie.transaction do
      CSV.foreach(path, headers: true) do |row|
        Movie.create!(
          genre: row["type"],
          title: row["title"],
          country: row["country"],
          published_at: row["date_added"],
          year: row["release_year"],
          description: row["description"]
        )
        count += 1
      end
    end
    update!(status: :completed, movies_count: count)
  end

  def mark_invalid_file(message)
    update!(status: :invalid_file, movies_count: 0, error_message: message)
    false
  end
end
