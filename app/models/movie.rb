class Movie < ApplicationRecord
  validates :title, presence: true, uniqueness: true
  validates :genre, presence: true
  validates :year, presence: true, numericality: {only_integer: true}
  validates :published_at, presence: true
end
