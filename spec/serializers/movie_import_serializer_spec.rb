require "rails_helper"

RSpec.describe MovieImportSerializer do
  context "quando a importação foi concluída" do
    let(:import) { MovieImport.create!(file_name: "netflix.csv", status: :completed, movies_count: 131) }

    it "expõe os atributos públicos com os valores corretos" do
      hash = described_class.new(import).serializable_hash

      expect(hash["file_name"]).to eq("netflix.csv")
      expect(hash["status"]).to eq("completed")
      expect(hash["movies_count"]).to eq(131)
      expect(hash["error_message"]).to be_nil
      expect(hash["id"]).to be_present
    end

    it "não expõe created_at nem updated_at" do
      hash = described_class.new(import).serializable_hash

      expect(hash).not_to include("created_at", "updated_at")
    end
  end

  context "quando a importação falhou" do
    let(:import) do
      MovieImport.create!(
        file_name: "broken.csv",
        status: :failed,
        movies_count: 0,
        error_message: "Title não pode ficar em branco"
      )
    end

    it "expõe a mensagem de erro junto com o status" do
      hash = described_class.new(import).serializable_hash

      expect(hash["status"]).to eq("failed")
      expect(hash["error_message"]).to eq("Title não pode ficar em branco")
      expect(hash["movies_count"]).to eq(0)
    end
  end
end
