RSpec.describe AocCli::Puzzle do
  subject(:puzzle) { described_class.new(**attributes) }

  let(:attributes) { { event:, day:, content:, input: }.compact }

  let(:event)   { AocCli::Event.create(year: 2020) }
  let(:day)     { 1 }
  let(:content) { "Puzzle contents" }
  let(:input)   { "foo bar baz" }

  describe "validations" do
    describe ":event" do
      context "when nil" do
        let(:event) { nil }

        include_examples :invalid, errors: ["Event can't be blank"]
      end

      context "when present" do
        let(:event) { AocCli::Event.create(year: 2020) }

        include_examples :valid
      end
    end

    describe ":day" do
      context "when nil" do
        let(:day) { nil }

        include_examples :invalid, errors: ["Day can't be blank"]
      end

      context "when not an integer" do
        let(:day) { :day }

        include_examples :invalid, errors: ["Day is not an integer"]
      end

      context "when negative" do
        let(:day) { -1 }

        include_examples :invalid, errors: ["Day is too small"]
      end

      context "when too low" do
        let(:day) { 0 }

        include_examples :invalid, errors: ["Day is too small"]
      end

      context "when too high" do
        let(:day) { 26 }

        include_examples :invalid, errors: ["Day is too large"]
      end

      context "when valid" do
        let(:day) { 1 }

        include_examples :valid
      end
    end

    describe ":contents" do
      context "when nil" do
        let(:content) { nil }

        include_examples :invalid, errors: ["Content can't be blank"]
      end

      context "when present" do
        let(:content) { "Puzzle content" }

        include_examples :valid
      end
    end

    describe ":input" do
      context "when nil" do
        let(:input) { nil }

        include_examples :invalid, errors: ["Input can't be blank"]
      end

      context "when present" do
        let(:input) { "foo bar baz" }

        include_examples :valid
      end
    end
  end
end
