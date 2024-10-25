class Movie < ApplicationRecord
  validates :title, presence: true, uniqueness: true
  validates :genre, presence: true
  validates :year, presence: true, numericality: {only_integer: true}
  validates :published_at, presence: true

  def self.ransackable_attributes(_auth_object = nil)
    [
      "title",
      "genre",
      "year",
      "country",
      "published_at",
      "description"
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
