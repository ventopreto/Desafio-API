require "rails_helper"

RSpec.describe Movie, type: :model do
  context "Validações" do
    it { should validate_presence_of(:title) }
    it { should validate_uniqueness_of(:title) }
    it { should validate_presence_of(:genre) }
    it { should validate_presence_of(:year) }
    it { should validate_numericality_of(:year).only_integer }
    it { should validate_presence_of(:published_at) }
  end
end
