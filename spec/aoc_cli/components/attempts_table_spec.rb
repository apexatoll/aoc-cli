RSpec.describe AocCli::Components::AttemptsTable do
  subject(:attempts_table) { described_class.new(puzzle:) }

  let(:year) { 2020 }

  let(:day) { 1 }

  let(:event) { create(:event, year:) }

  let!(:puzzle) { create(:puzzle, event:, day:) }

  describe "#render" do
    subject(:render) { attempts_table.render }

    shared_examples :renders_expected_table do
      it "renders the expected table" do
        expect { render }.to output(expected_table).to_stdout
      end
    end

    def create_attempt(status, answer:, level:, hour:, minute:)
      created_at = DateTime.new(2023, 12, 1, hour, minute)

      create(:attempt, status, puzzle:, level:, answer:, created_at:)
    end

    def create_attempts(level:, hour:)
      5.times do |i|
        create_attempt(:incorrect, level:, hour:, answer: i * 1000, minute: i)
      end

      create_attempt(:too_low, level:, hour:, answer: 5000, minute: 5)
      create_attempt(:correct, level:, hour:, answer: 5001, minute: 6)
    end

    context "when puzzle has no attempts" do
      it "returns the expected message" do
        expect { render }.to output(<<~TEXT).to_stdout
          No attempts have been made for this puzzle.
        TEXT
      end
    end

    context "when puzzle only has attempts for level one" do
      before { create_attempts(level: 1, hour: 10) }

      include_examples :renders_expected_table do
        let(:expected_table) do
          <<~TEXT
            ┌──────────────────────────────────────────────────────────┐
            │                Advent of Code: 2020-12-01                │
            ├────────┬───────────┬───────────────────────────┬─────────┤
            │ Answer │  Status   │           Time            │  Hint   │
            ╞════════╪═══════════╪═══════════════════════════╪═════════╡
            │   0    │ Incorrect │ 2023-12-01 10:00:00 +0000 │    -    │
            │  1000  │ Incorrect │ 2023-12-01 10:01:00 +0000 │    -    │
            │  2000  │ Incorrect │ 2023-12-01 10:02:00 +0000 │    -    │
            │  3000  │ Incorrect │ 2023-12-01 10:03:00 +0000 │    -    │
            │  4000  │ Incorrect │ 2023-12-01 10:04:00 +0000 │    -    │
            │  5000  │ Incorrect │ 2023-12-01 10:05:00 +0000 │ Too low │
            │  5001  │  Correct  │ 2023-12-01 10:06:00 +0000 │    -    │
            └────────┴───────────┴───────────────────────────┴─────────┘
          TEXT
        end
      end
    end

    context "when puzzle only has attempts for level two" do
      before { create_attempts(level: 2, hour: 11) }

      include_examples :renders_expected_table do
        let(:expected_table) do
          <<~TEXT
            ┌──────────────────────────────────────────────────────────┐
            │                Advent of Code: 2020-12-01                │
            ├────────┬───────────┬───────────────────────────┬─────────┤
            │ Answer │  Status   │           Time            │  Hint   │
            ╞════════╪═══════════╪═══════════════════════════╪═════════╡
            │   0    │ Incorrect │ 2023-12-01 11:00:00 +0000 │    -    │
            │  1000  │ Incorrect │ 2023-12-01 11:01:00 +0000 │    -    │
            │  2000  │ Incorrect │ 2023-12-01 11:02:00 +0000 │    -    │
            │  3000  │ Incorrect │ 2023-12-01 11:03:00 +0000 │    -    │
            │  4000  │ Incorrect │ 2023-12-01 11:04:00 +0000 │    -    │
            │  5000  │ Incorrect │ 2023-12-01 11:05:00 +0000 │ Too low │
            │  5001  │  Correct  │ 2023-12-01 11:06:00 +0000 │    -    │
            └────────┴───────────┴───────────────────────────┴─────────┘
          TEXT
        end
      end
    end

    context "when puzzle has attempts for both levels" do
      before do
        create_attempts(level: 1, hour: 20)
        create_attempts(level: 2, hour: 21)
      end

      include_examples :renders_expected_table do
        let(:expected_table) do
          <<~TEXT
            ┌──────────────────────────────────────────────────────────┐
            │                Advent of Code: 2020-12-01                │
            ├────────┬───────────┬───────────────────────────┬─────────┤
            │ Answer │  Status   │           Time            │  Hint   │
            ╞════════╪═══════════╪═══════════════════════════╪═════════╡
            │   0    │ Incorrect │ 2023-12-01 20:00:00 +0000 │    -    │
            │  1000  │ Incorrect │ 2023-12-01 20:01:00 +0000 │    -    │
            │  2000  │ Incorrect │ 2023-12-01 20:02:00 +0000 │    -    │
            │  3000  │ Incorrect │ 2023-12-01 20:03:00 +0000 │    -    │
            │  4000  │ Incorrect │ 2023-12-01 20:04:00 +0000 │    -    │
            │  5000  │ Incorrect │ 2023-12-01 20:05:00 +0000 │ Too low │
            │  5001  │  Correct  │ 2023-12-01 20:06:00 +0000 │    -    │
            ├────────┼───────────┼───────────────────────────┼─────────┤
            │   0    │ Incorrect │ 2023-12-01 21:00:00 +0000 │    -    │
            │  1000  │ Incorrect │ 2023-12-01 21:01:00 +0000 │    -    │
            │  2000  │ Incorrect │ 2023-12-01 21:02:00 +0000 │    -    │
            │  3000  │ Incorrect │ 2023-12-01 21:03:00 +0000 │    -    │
            │  4000  │ Incorrect │ 2023-12-01 21:04:00 +0000 │    -    │
            │  5000  │ Incorrect │ 2023-12-01 21:05:00 +0000 │ Too low │
            │  5001  │  Correct  │ 2023-12-01 21:06:00 +0000 │    -    │
            └────────┴───────────┴───────────────────────────┴─────────┘
          TEXT
        end
      end
    end
  end
end
