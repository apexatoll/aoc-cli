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

  describe "#complete?" do
    let(:started_at) { now - 5000 }

    context "when incomplete" do
      it "returns false" do
        expect(progress).not_to be_complete
      end
    end

    context "when complete" do
      before { progress.complete! }

      it "returns true" do
        expect(progress).to be_complete
      end
    end
  end

  describe "#complete!" do
    subject(:complete!) { progress.complete! }

    let(:started_at) { now - 5000 }

    it "updates the completed_at timestamp" do
      expect { complete! }
        .to change { progress.reload.completed_at }
        .from(nil)
        .to(now)
    end
  end

  describe "#reset!" do
    subject(:reset!) { progress.reset! }

    let(:started_at) { now - 5000 }

    it "updates the started_at timestamp" do
      expect { reset! }
        .to change { progress.reload.started_at }
        .from(started_at)
        .to(now)
    end
  end
end
