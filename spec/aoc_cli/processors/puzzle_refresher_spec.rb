RSpec.describe AocCli::Processors::PuzzleRefresher do
  subject(:puzzle_refresher) { described_class.new(**attributes) }

  let(:attributes) { { year:, day: }.compact }

  describe "validations" do
    let(:year) { 2021 }

    let(:day) { 2 }

    context "when year is nil" do
      let(:year) { nil }

      include_examples :invalid, errors: ["Year can't be blank"]
    end

    context "when year is not an integer" do
      let(:year) { :foobar }

      include_examples :invalid, errors: ["Year is not an integer"]
    end

    context "when year is before first AoC event" do
      let(:year) { 2014 }

      include_examples :invalid, errors: [
        "Year is before first Advent of Code event (2015)"
      ]
    end

    context "when year is after most recent AoC event" do
      let(:year) { 2028 }

      include_examples :invalid, errors: ["Year is in the future"]
    end

    context "when year is valid" do
      let(:year) { 2021 }

      context "and day is nil" do
        let(:day) { nil }

        include_examples :invalid, errors: ["Day can't be blank"]
      end

      context "and day is not an integer" do
        let(:day) { :foobar }

        include_examples :invalid, errors: ["Day is not an integer"]
      end

      context "and day is less than 1" do
        let(:day) { 0 }

        include_examples :invalid, errors: ["Day is too small"]
      end

      context "and day is more than 25" do
        let(:day) { 26 }

        include_examples :invalid, errors: ["Day is too large"]
      end

      context "and day is valid" do
        let(:day) { 8 }

        context "and event does not exist" do
          include_examples :invalid, errors: ["Event can't be blank"]
        end

        context "and event exists" do
          before { create(:event, year:) }

          include_examples :valid
        end
      end
    end
  end

  describe "#run" do
    subject(:run) { puzzle_refresher.run }

    let(:year) { 2017 }

    let(:day) { 3 }

    let(:content) { "Puzzle content" }

    let(:input) { "foobar" }

    before do
      allow(AocCli::Core::Repository)
        .to receive(:get_puzzle)
        .with(year:, day:)
        .and_return(content)

      allow(AocCli::Core::Repository)
        .to receive(:get_input)
        .with(year:, day:)
        .and_return(input)
    end

    context "when invalid" do
      it "does not fetch the puzzle content" do
        run

        expect(AocCli::Core::Repository)
          .not_to have_received(:get_puzzle)
          .with(year:, day:)
      end

      it "does not fetch the puzzle input" do
        run

        expect(AocCli::Core::Repository)
          .not_to have_received(:get_input)
          .with(year:, day:)
      end

      it "does not create a Puzzle record" do
        expect { run }.not_to change { AocCli::Puzzle.count }
      end

      it "returns nil" do
        expect(run).to be_nil
      end
    end

    context "when valid" do
      let!(:event) { create(:event, year:) }

      context "and puzzle does not already exist" do
        let(:puzzle) { AocCli::Puzzle.last }

        it "fetches the puzzle content" do
          run

          expect(AocCli::Core::Repository)
            .to have_received(:get_puzzle)
            .with(year:, day:)
            .once
        end

        it "fetches the puzzle input" do
          run

          expect(AocCli::Core::Repository)
            .to have_received(:get_input)
            .with(year:, day:)
            .once
        end

        it "creates a Puzzle record" do
          expect { run }.to change { AocCli::Puzzle.count }.by(1)
        end

        it "sets the expected Puzzle attributes" do
          run
          expect(puzzle).to have_attributes(event:, day:, content:, input:)
        end

        it "returns the created Puzzle record" do
          expect(run).to eq(puzzle)
        end
      end

      context "and puzzle already exists" do
        let!(:puzzle) { create(:puzzle, event:, day:) }

        it "fetches the puzzle content" do
          run

          expect(AocCli::Core::Repository)
            .to have_received(:get_puzzle)
            .with(year:, day:)
            .once
        end

        it "fetches the puzzle input" do
          run

          expect(AocCli::Core::Repository)
            .to have_received(:get_input)
            .with(year:, day:)
            .once
        end

        it "does not create a Puzzle record" do
          expect { run }.not_to change { AocCli::Puzzle.count }
        end

        it "updates the existing Puzzle attributes" do
          expect { run }
            .to change { puzzle.reload.values }
            .to(include(content:, input:))
        end

        it "returns the updated Puzzle record" do
          expect(run.reload).to eq(puzzle.reload)
        end
      end
    end
  end
end
