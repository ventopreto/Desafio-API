class AddDefaultToCreatedAtAndUpdatedAt < ActiveRecord::Migration[6.1]
  def change
    change_column_default :movies, :created_at, -> { "CURRENT_TIMESTAMP" }
    change_column_default :movies, :updated_at, -> { "CURRENT_TIMESTAMP" }
  end
end
