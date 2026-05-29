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

  it "serializa os atributos públicos com os valores corretos" do
    hash = described_class.new(movie).serializable_hash

    expect(hash["title"]).to eq("Hereditary")
    expect(hash["genre"]).to eq("Movie")
    expect(hash["year"]).to eq(2018)
    expect(hash["country"]).to eq("USA")
    expect(hash["description"]).to eq("Family horror")
    expect(hash["id"]).to be_present
    expect(hash["published_at"]).to be_present
  end

  it "não expõe created_at nem updated_at" do
    hash = described_class.new(movie).serializable_hash

    expect(hash).not_to include("created_at", "updated_at")
  end

  it "serializa uma coleção mantendo o contrato em cada item" do
    other = Movie.create!(title: "Other", genre: "Movie", year: 2019, country: "USA", published_at: "2019-01-01")

    hashes = described_class.new([movie, other]).serializable_hash

    expect(hashes.pluck("title")).to contain_exactly("Hereditary", "Other")
    expect(hashes.first.keys).not_to include("created_at", "updated_at")
  end
end
