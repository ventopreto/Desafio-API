class Api::V1::MovieImportsController < ApplicationController
  def show
    import = MovieImport.find(params[:id])
    render json: import.as_json(except: [:created_at, :updated_at]), status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: {error: I18n.t("messages.import.not_found")}, status: :not_found
  end
end
