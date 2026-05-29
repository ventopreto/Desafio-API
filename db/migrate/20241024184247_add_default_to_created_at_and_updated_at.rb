class AddDefaultToCreatedAtAndUpdatedAt < ActiveRecord::Migration[6.1]
  def change
    change_column_default :movies, :created_at, from: nil, to: -> { "CURRENT_TIMESTAMP" }
    change_column_default :movies, :updated_at, from: nil, to: -> { "CURRENT_TIMESTAMP" }
  end
end
