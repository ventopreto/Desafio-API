class Api::V1::MovieImportsController < ApplicationController
  def show
    import = MovieImport.find(params[:id])
    render json: MovieImportSerializer.new(import).serializable_hash, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: {error: I18n.t("messages.import.not_found")}, status: :not_found
  end
end
