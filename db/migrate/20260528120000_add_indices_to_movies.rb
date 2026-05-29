class AddIndicesToMovies < ActiveRecord::Migration[6.1]
  def change
    add_index :movies, :title, unique: true
    add_index :movies, :year
    add_index :movies, :genre
    add_index :movies, :country
    add_index :movies, :published_at
  end
end
