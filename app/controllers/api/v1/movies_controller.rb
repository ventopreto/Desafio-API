class Api::V1::MoviesController < ApplicationController
  rescue_from ArgumentError, with: :invalid_param_message

  def create
    uploaded_file = params[:file]
    import = MovieImport.create(file_name: uploaded_file.original_filename, status: 1)

    if import.import_movies(uploaded_file)
      render json: {message: I18n.t("messages.import.success")}, status: :created
    else
      render json: {error: I18n.t("messages.import.failed", error_message: import.error_message)}, status: :unprocessable_entity
    end
  end

  def index
    @query = Movie.all.ransack(params[:query])
    @query.sorts = "year asc" if @query.sorts.empty?
    @movies = @query.result

    if @movies.empty?
      render json: {message: I18n.t("messages.movies.not_found")}, status: :ok
    else
      render json: @movies.as_json(except: [:created_at, :updated_at]), status: :ok
    end
  end

  private

  def invalid_param_message
    render json: {error: I18n.t("messages.movies.invalid_query_params")}, status: :bad_request
  end
end
