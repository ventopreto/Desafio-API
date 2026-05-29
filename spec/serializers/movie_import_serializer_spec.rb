require "rails_helper"

RSpec.describe MovieImportSerializer do
  let(:import) { MovieImport.create!(file_name: "netflix.csv", status: :completed, movies_count: 131) }

  it "exposes only the public fields" do
    hash = described_class.new(import).serializable_hash

    expect(hash.keys).to match_array(%w[id file_name error_message status movies_count])
  end

  it "does not leak created_at or updated_at" do
    hash = described_class.new(import).serializable_hash

    expect(hash).not_to include("created_at", "updated_at")
  end
end
