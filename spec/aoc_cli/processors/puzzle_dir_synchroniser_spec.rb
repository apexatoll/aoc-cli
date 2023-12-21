RSpec.describe AocCli::Processors::PuzzleDirSynchroniser, :with_temp_dir do
  subject(:puzzle_dir_synchroniser) { described_class.new(**attributes) }

  let(:attributes) { { puzzle:, location:, skip_cache: }.compact }

  let(:puzzle) { create(:puzzle) }

  let(:location) { create(:location, :puzzle_dir, puzzle:, path:) }

  let(:skip_cache) { nil }

  describe "validations" do
    context "when puzzle is nil" do
      let(:puzzle) { nil }
      let(:location) { create(:location, :puzzle_dir) }

      include_examples :invalid, errors: ["Puzzle can't be blank"]
    end

    context "when location is nil" do
      let(:location) { nil }

      include_examples :invalid, errors: ["Location can't be blank"]
    end

    context "when puzzle dir does not exist" do
      let(:path) { temp_path("does-not-exist").to_s }

      include_examples :invalid, errors: ["Puzzle dir does not exist"]
    end

    context "when puzzle dir exists" do
      let(:path) { temp_dir }

      include_examples :valid
    end
  end
end
