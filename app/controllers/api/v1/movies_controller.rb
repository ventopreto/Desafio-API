class Api::V1::MoviesController < ApplicationController
  def create
    uploaded_file = params[:file]
    import = MovieImport.create(file_name: uploaded_file.original_filename, status: 1)

    if import.import_movies(uploaded_file)
      render json: {message: I18n.t("messages.import.success")}, status: :created
    else
      render json: {error: I18n.t("messages.import.failed", error_message: import.error_message)}, status: :unprocessable_entity
    end
  end
end
