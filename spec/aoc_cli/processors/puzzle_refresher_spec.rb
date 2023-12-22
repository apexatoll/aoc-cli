RSpec.describe AocCli::Processors::PuzzleRefresher do
  describe ".run!" do
    subject(:run!) { described_class.run!(puzzle:) }

    context "when puzzle is not a Puzzle record" do
      let(:puzzle) { create(:event) }

      include_examples :failed_process, errors: [
        "Puzzle has incompatible type"
      ]
    end

    context "when puzzle is a Puzzle record" do
      let(:puzzle) { create(:puzzle) }

      before do
        stub_request(:get, puzzle_url(puzzle))
          .to_return(body: wrap_in_html(fetched_puzzle))

        stub_request(:get, input_url(puzzle))
          .to_return(body: fetched_input)
      end

      context "when cached puzzle is still valid" do
        let(:fetched_puzzle) { puzzle.content }
        let(:fetched_input)  { puzzle.input }

        it "requests the puzzle" do
          run!
          assert_requested(:get, puzzle_url(puzzle))
        end

        it "requests the input" do
          run!
          assert_requested(:get, input_url(puzzle))
        end

        it "does not update the puzzle" do
          expect { run! }.not_to change { puzzle.reload.values }
        end

        it "returns the Puzzle" do
          expect(run!).to eq(puzzle)
        end
      end

      context "when cached puzzle is invalid" do
        let(:fetched_puzzle) { puzzle.content.reverse }
        let(:fetched_input)  { puzzle.input.reverse }

        it "requests the puzzle" do
          run!
          assert_requested(:get, puzzle_url(puzzle))
        end

        it "requests the input" do
          run!
          assert_requested(:get, input_url(puzzle))
        end

        it "updates the puzzle to the fetched values" do
          expect { run! }
            .to change { puzzle.reload.values }
            .to include(content: fetched_puzzle, input: fetched_input)
        end

        it "returns the Puzzle" do
          expect(run!).to eq(puzzle)
        end
      end
    end
  end
end
