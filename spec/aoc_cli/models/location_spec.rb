RSpec.describe AocCli::Location do
  subject(:location) { described_class.new(**attributes) }

  let(:attributes) { { path:, resource: } }

  let(:path) { "/foo/bar/baz" }

  let(:resource) { create(:event) }

  describe "validations" do
    let(:resource) { create(:event) }

    describe ":path" do
      context "when nil" do
        let(:path) { nil }

        include_examples :invalid, errors: ["Path can't be blank"]
      end

      context "when present" do
        let(:path) { "/foo/bar/baz" }

        include_examples :valid
      end
    end

    describe ":resource" do
      context "when resource is nil" do
        let(:resource) { nil }

        include_examples :invalid, errors: ["Resource can't be blank"]
      end

      context "when resource is an Event" do
        let(:resource) { create(:event) }

        include_examples :valid
      end

      context "when resource is a Puzzle" do
        let(:resource) { create(:puzzle) }

        include_examples :valid
      end
    end
  end

  describe "#exists?", :with_temp_dir do
    subject(:exists?) { location.exists? }

    context "when path does not exist" do
      let(:path) { temp_path("some-dir").to_s }

      it "returns false" do
        expect(exists?).to be(false)
      end
    end

    context "when path exists" do
      let(:path) { temp_dir.to_s }

      it "returns true" do
        expect(exists?).to be(true)
      end
    end
  end

  describe "#event_dir?" do
    context "when resource is an Event" do
      let(:resource) { create(:event) }

      it "returns true" do
        expect(location).to be_an_event_dir
      end
    end

    context "when resource is a Puzzle" do
      let(:resource) { create(:puzzle) }

      it "returns false" do
        expect(location).not_to be_an_event_dir
      end
    end
  end

  describe "#puzzle_dir?" do
    context "when resource is an Event" do
      let(:resource) { create(:event) }

      it "returns false" do
        expect(location).not_to be_a_puzzle_dir
      end
    end

    context "when resource is a Puzzle" do
      let(:resource) { create(:puzzle) }

      it "returns true" do
        expect(location).to be_a_puzzle_dir
      end
    end
  end
end
