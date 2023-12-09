RSpec.describe AocCli::Location do
  subject(:location) { described_class.new(**attributes) }

  let(:attributes) { { path:, resource: } }

  describe "validations" do
    let(:path) { "/foo/bar/baz" }

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
end
