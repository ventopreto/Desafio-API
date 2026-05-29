require "rails_helper"

RSpec.describe MovieSerializer do
  let(:movie) do
    Movie.create!(
      title: "Hereditary",
      genre: "Movie",
      year: 2018,
      country: "USA",
      published_at: "2018-08-01",
      description: "Family horror"
    )
  end

  it "exposes only the public fields" do
    hash = described_class.new(movie).serializable_hash

    expect(hash.keys).to match_array(%w[id title genre year country published_at description])
  end

  it "does not leak created_at or updated_at" do
    hash = described_class.new(movie).serializable_hash

    expect(hash).not_to include("created_at", "updated_at")
  end

  it "serializes a collection" do
    other = Movie.create!(title: "Other", genre: "Movie", year: 2019, country: "USA", published_at: "2019-01-01")

    hashes = described_class.new([movie, other]).serializable_hash

    expect(hashes.pluck("title")).to contain_exactly("Hereditary", "Other")
  end
end
