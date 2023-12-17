RSpec.describe AocCli::Components::ProgressTable do
  subject(:progress_table) { described_class.new(event:) }

  let(:event) { create(:event, year:) }

  let(:year) { 2023 }

  let!(:stats) { create(:stats, event:, **stats_hash) }

  describe "#render" do
    subject(:render) { progress_table.render }

    context "when no progress has been made on given event" do
      let(:stats_hash) { {} }

      let(:expected_table) do
        <<~TABLE
          ┌──────────────────────┐
          │ Advent of Code: 2023 │
          ├───────────┬──────────┤
          │    Day    │ Progress │
          ╞═══════════╪══════════╡
          │   Day 1   │   ○ ○    │
          │   Day 2   │   ○ ○    │
          │   Day 3   │   ○ ○    │
          │   Day 4   │   ○ ○    │
          │   Day 5   │   ○ ○    │
          │   Day 6   │   ○ ○    │
          │   Day 7   │   ○ ○    │
          │   Day 8   │   ○ ○    │
          │   Day 9   │   ○ ○    │
          │  Day 10   │   ○ ○    │
          │  Day 11   │   ○ ○    │
          │  Day 12   │   ○ ○    │
          │  Day 13   │   ○ ○    │
          │  Day 14   │   ○ ○    │
          │  Day 15   │   ○ ○    │
          │  Day 16   │   ○ ○    │
          │  Day 17   │   ○ ○    │
          │  Day 18   │   ○ ○    │
          │  Day 19   │   ○ ○    │
          │  Day 20   │   ○ ○    │
          │  Day 21   │   ○ ○    │
          │  Day 22   │   ○ ○    │
          │  Day 23   │   ○ ○    │
          │  Day 24   │   ○ ○    │
          │  Day 25   │   ○ ○    │
          ├───────────┼──────────┤
          │   Total   │   0/50   │
          └───────────┴──────────┘
        TABLE
      end

      it "outputs the expected table" do
        expect { render }.to output(expected_table).to_stdout
      end
    end

    context "when some progress has been made on given event" do
      let(:stats_hash) { { day_1: 2, day_2: 1, day_3: 1, day_8: 2 } }

      let(:expected_table) do
        <<~TABLE
          ┌──────────────────────┐
          │ Advent of Code: 2023 │
          ├───────────┬──────────┤
          │    Day    │ Progress │
          ╞═══════════╪══════════╡
          │   Day 1   │   ● ●    │
          │   Day 2   │   ● ○    │
          │   Day 3   │   ● ○    │
          │   Day 4   │   ○ ○    │
          │   Day 5   │   ○ ○    │
          │   Day 6   │   ○ ○    │
          │   Day 7   │   ○ ○    │
          │   Day 8   │   ● ●    │
          │   Day 9   │   ○ ○    │
          │  Day 10   │   ○ ○    │
          │  Day 11   │   ○ ○    │
          │  Day 12   │   ○ ○    │
          │  Day 13   │   ○ ○    │
          │  Day 14   │   ○ ○    │
          │  Day 15   │   ○ ○    │
          │  Day 16   │   ○ ○    │
          │  Day 17   │   ○ ○    │
          │  Day 18   │   ○ ○    │
          │  Day 19   │   ○ ○    │
          │  Day 20   │   ○ ○    │
          │  Day 21   │   ○ ○    │
          │  Day 22   │   ○ ○    │
          │  Day 23   │   ○ ○    │
          │  Day 24   │   ○ ○    │
          │  Day 25   │   ○ ○    │
          ├───────────┼──────────┤
          │   Total   │   6/50   │
          └───────────┴──────────┘
        TABLE
      end

      it "outputs the expected table" do
        expect { render }.to output(expected_table).to_stdout
      end
    end

    context "when given event is complete" do
      let(:stats_hash) do
        {
          day_1: 2,  day_2: 2,  day_3: 2,  day_4: 2,  day_5: 2,
          day_6: 2,  day_7: 2,  day_8: 2,  day_9: 2,  day_10: 2,
          day_11: 2, day_12: 2, day_13: 2, day_14: 2, day_15: 2,
          day_16: 2, day_17: 2, day_18: 2, day_19: 2, day_20: 2,
          day_21: 2, day_22: 2, day_23: 2, day_24: 2, day_25: 2
        }
      end

      let(:expected_table) do
        <<~TABLE
          ┌──────────────────────┐
          │ Advent of Code: 2023 │
          ├───────────┬──────────┤
          │    Day    │ Progress │
          ╞═══════════╪══════════╡
          │   Day 1   │   ● ●    │
          │   Day 2   │   ● ●    │
          │   Day 3   │   ● ●    │
          │   Day 4   │   ● ●    │
          │   Day 5   │   ● ●    │
          │   Day 6   │   ● ●    │
          │   Day 7   │   ● ●    │
          │   Day 8   │   ● ●    │
          │   Day 9   │   ● ●    │
          │  Day 10   │   ● ●    │
          │  Day 11   │   ● ●    │
          │  Day 12   │   ● ●    │
          │  Day 13   │   ● ●    │
          │  Day 14   │   ● ●    │
          │  Day 15   │   ● ●    │
          │  Day 16   │   ● ●    │
          │  Day 17   │   ● ●    │
          │  Day 18   │   ● ●    │
          │  Day 19   │   ● ●    │
          │  Day 20   │   ● ●    │
          │  Day 21   │   ● ●    │
          │  Day 22   │   ● ●    │
          │  Day 23   │   ● ●    │
          │  Day 24   │   ● ●    │
          │  Day 25   │   ● ●    │
          ├───────────┼──────────┤
          │   Total   │  50/50   │
          └───────────┴──────────┘
        TABLE
      end

      it "outputs the expected table" do
        expect { render }.to output(expected_table).to_stdout
      end
    end
  end
end
