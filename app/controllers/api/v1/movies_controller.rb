class Api::V1::MoviesController < ApplicationController
  rescue_from ActionController::BadRequest, with: :handle_invalid_request

  def create
    uploaded_file = params[:file]
    result = Movie.insert_all(remove_unused_data(uploaded_file)) if validates_csv_file(uploaded_file)
    if result && result.count > 0
      render json: {message: "#{result.rows.size} Filmes adicionados com sucesso."}, status: :created
    else
      render json: {error: "Falha ao adicionar os filmes."}, status: :unprocessable_entity
    end
  end

  private

  def validates_csv_file(uploaded_file)
    if uploaded_file.nil?
      raise ActionController::BadRequest, "Nenhum arquivo foi enviado. Por favor, envie um arquivo CSV."
    elsif uploaded_file.content_type != "text/csv"
      raise ActionController::BadRequest, "Formato de arquivo inválido. Por favor, envie um arquivo CSV."
    end
    true
  end

  def remove_unused_data(data)
    require "csv"
    CSV.readlines(data).map!.with_index do |row, index|
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

  def handle_invalid_request(exception)
    render json: {error: exception.message}, status: :unprocessable_entity
  end
end
