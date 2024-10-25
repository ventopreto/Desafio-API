class CreateMovieImports < ActiveRecord::Migration[6.1]
  def change
    create_table :movie_imports do |t|
      t.string :file_name
      t.string :error_message
      t.integer :status
      t.integer :movies_count

      t.timestamps
    end
  end
end
