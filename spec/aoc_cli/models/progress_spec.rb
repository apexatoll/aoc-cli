RSpec.describe AocCli::Progress do
  subject(:progress) { described_class.create(**attributes) }

  let(:attributes) { { puzzle:, level:, started_at: }.compact }

  let(:puzzle) { create(:puzzle) }

  let(:level) { 1 }

  let(:started_at) { now }

  let(:now) { Time.now.round(6) }

  before { allow(Time).to receive(:now).and_return(now) }

  describe "validations" do
    subject(:progress) { described_class.new(**attributes) }

    describe ":puzzle" do
      context "when nil" do
        let(:puzzle) { nil }

        include_examples :invalid, errors: ["Puzzle can't be blank"]
      end

      context "when present" do
        let(:puzzle) { create(:puzzle) }

        include_examples :valid
      end
    end

    describe ":level" do
      context "when nil" do
        let(:level) { nil }

        include_examples :invalid, errors: ["Level can't be blank"]
      end

      context "when not an integer" do
        let(:level) { :level }

        include_examples :invalid, errors: ["Level is not an integer"]
      end

      context "when too low" do
        let(:level) { 0 }

        include_examples :invalid, errors: ["Level is too small"]
      end

      context "when too high" do
        let(:level) { 3 }

        include_examples :invalid, errors: ["Level is too large"]
      end

      context "when 1" do
        let(:level) { 1 }

        include_examples :valid
      end

      context "when 2" do
        let(:level) { 2 }

        include_examples :valid
      end
    end

    describe ":started_at" do
      context "when nil" do
        let(:started_at) { nil }

        include_examples :invalid, errors: ["Started at can't be blank"]
      end

      context "when present" do
        let(:started_at) { now }

        include_examples :valid
      end
    end
  end
end
