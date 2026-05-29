class MovieSerializer
  include Alba::Resource

  attributes :id, :title, :genre, :year, :country, :published_at, :description
end
