RSpec.describe AocCli::Puzzle do
  subject(:puzzle) { described_class.create(**attributes) }

  let(:attributes) { { event:, day:, content:, input: }.compact }

  let(:event)   { AocCli::Event.create(year: 2020) }
  let(:day)     { 1 }
  let(:content) { "Puzzle contents" }
  let(:input)   { "foo bar baz" }

  describe "validations" do
    subject(:puzzle) { described_class.new(**attributes) }

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
      include_examples :validates_puzzle_day
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

  describe "#mark_complete!" do
    subject(:mark_complete!) { puzzle.mark_complete!(level) }

    before { allow(Time).to receive(:now).and_return(Time.now) }

    context "when level is 0" do
      let(:level) { 0 }

      it "raises an error" do
        expect { mark_complete! }.to raise_error("invalid level")
      end
    end

    context "when level is 1" do
      let(:level) { 1 }

      it "updates the part_one_completed_at timestamp" do
        expect { mark_complete! }
          .to change { puzzle.reload.part_one_completed_at }
          .from(nil)
          .to(Time.now)
      end

      it "does not update the part_two_completed_at timestamp" do
        expect { mark_complete! }
          .not_to change { puzzle.reload.part_two_completed_at }
          .from(nil)
      end
    end

    context "when level is 2" do
      let(:level) { 2 }

      it "does not update the part_one_completed_at timestamp" do
        expect { mark_complete! }
          .not_to change { puzzle.reload.part_one_completed_at }
          .from(nil)
      end

      it "updates the part_two_completed_at timestamp" do
        expect { mark_complete! }
          .to change { puzzle.reload.part_two_completed_at }
          .from(nil)
          .to(Time.now)
      end
    end

    context "when level is greater than 2" do
      let(:level) { 3 }

      it "raises an error" do
        expect { mark_complete! }.to raise_error("invalid level")
      end
    end
  end
end
