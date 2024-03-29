RSpec.describe AocCli::Presenters::PuzzlePresenter do
  subject(:presenter) { described_class.new(puzzle) }

  let(:event) { create(:event, year:) }

  let(:puzzle) { create(:puzzle, event:, day:) }

  let(:year) { 2016 }

  describe "#date" do
    subject(:date) { presenter.date }

    context "when day is single digit" do
      let(:day) { 8 }

      it "returns the expected date" do
        expect(date).to eq("2016-12-08")
      end
    end

    context "when day is double digit" do
      let(:day) { 10 }

      it "returns the expected date" do
        expect(date).to eq("2016-12-10")
      end
    end
  end

  describe "#puzzle_filename" do
    subject(:puzzle_filename) { presenter.puzzle_filename }

    context "when day is single digit" do
      let(:day) { 8 }

      it "returns the expected filename" do
        expect(puzzle_filename).to eq("day_08.md")
      end
    end

    context "when day is double digit" do
      let(:day) { 10 }

      it "returns the expected date" do
        expect(puzzle_filename).to eq("day_10.md")
      end
    end
  end
end
