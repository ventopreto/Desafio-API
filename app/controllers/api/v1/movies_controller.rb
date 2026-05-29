require "fileutils"

class Api::V1::MoviesController < ApplicationController
  MAX_UPLOAD_BYTES = 10.megabytes

  rescue_from ArgumentError, with: :invalid_param_message

  def create
    uploaded_file = params[:file]
    unless uploaded_file.respond_to?(:original_filename)
      return render json: {error: I18n.t("messages.import.missing_file")}, status: :bad_request
    end

    if uploaded_file.size > MAX_UPLOAD_BYTES
      return render json: {
        error: I18n.t("messages.import.too_large", limit: ActiveSupport::NumberHelper.number_to_human_size(MAX_UPLOAD_BYTES))
      }, status: :content_too_large
    end

    import = MovieImport.create!(file_name: uploaded_file.original_filename, status: :processing)
    path = persist_upload(uploaded_file, import.id)
    ImportMoviesJob.perform_later(import.id, path, uploaded_file.content_type)

    render json: {
      message: I18n.t("messages.import.accepted"),
      import_id: import.id
    }, status: :accepted
  end

  def index
    @query = Movie.all.ransack(params[:query])
    @query.sorts = "year asc" if @query.sorts.empty?
    @pagy, @movies = pagy(@query.result)
    @movies = @movies.to_a
    pagy_headers_merge(@pagy)

    if @movies.empty?
      render json: {message: I18n.t("messages.movies.not_found")}, status: :ok
    else
      render json: @movies.as_json(except: [:created_at, :updated_at]), status: :ok
    end
  end

  private

  def persist_upload(uploaded_file, id)
    dir = Rails.root.join("tmp/imports")
    FileUtils.mkdir_p(dir)
    extension = File.extname(uploaded_file.original_filename)
    path = dir.join("#{id}#{extension}").to_s
    File.binwrite(path, uploaded_file.read)
    path
  end

  def invalid_param_message
    render json: {error: I18n.t("messages.movies.invalid_query_params")}, status: :bad_request
  end
end
