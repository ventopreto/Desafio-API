class Api::V1::MoviesController < ApplicationController
  def create
    uploaded_file = params[:file]
    import = MovieImport.create(file_name: uploaded_file.original_filename, status: 1)

    if import.import_movies(uploaded_file)
      render json: {message: "#{import.movies_count} Filmes adicionados com sucesso."}, status: :created
    else
      render json: {error: "Erro na importação. #{import.error_message}"}, status: :unprocessable_entity
    end
  end
end
