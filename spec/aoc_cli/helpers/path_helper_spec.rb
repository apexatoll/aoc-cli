RSpec.describe AocCli::Helpers::PathHelper do
  subject(:target) { Class.new { include AocCli::Helpers::PathHelper }.new }

  before do
    allow(File).to receive(:expand_path).with(".").and_return(current_path)
  end

  let(:current_path) { "/foo/bar" }

  describe "#current_year" do
    subject(:current_year) { target.current_year }

    context "when current dir is neither an event nor a puzzle directory" do
      it "returns nil" do
        expect(current_year).to be_nil
      end
    end

    context "when current dir is an event directory" do
      before { create(:location, :year_dir, event:, path: current_path) }

      let(:event) { create(:event) }

      it "returns the event year" do
        expect(current_year).to eq(event.year)
      end
    end

    context "when current dir is a puzzle directory" do
      before { create(:location, :puzzle_dir, puzzle:, path: current_path) }

      let(:puzzle) { create(:puzzle, event:) }

      let(:event) { create(:event) }

      it "returns the puzzle event year" do
        expect(current_year).to eq(event.year)
      end
    end
  end

  describe "#current_day" do
    subject(:current_day) { target.current_day }

    context "when current dir is neither an event nor a puzzle directory" do
      it "returns nil" do
        expect(current_day).to be_nil
      end
    end

    context "when current dir is an event directory" do
      before { create(:location, :year_dir, event:, path: current_path) }

      let(:event) { create(:event) }

      it "returns nil" do
        expect(current_day).to be_nil
      end
    end

    context "when current dir is a puzzle directory" do
      before { create(:location, :puzzle_dir, puzzle:, path: current_path) }

      let(:puzzle) { create(:puzzle, event:) }

      let(:event) { create(:event) }

      it "returns the puzzle day" do
        expect(current_day).to eq(puzzle.day)
      end
    end
  end

  describe "#in_event_dir?" do
    subject(:in_event_dir?) { target.in_event_dir? }

    context "when current dir is neither an event nor a puzzle directory" do
      it "returns false" do
        expect(in_event_dir?).to be(false)
      end
    end

    context "when current dir is an event directory" do
      before { create(:location, :year_dir, path: current_path) }

      it "returns true" do
        expect(in_event_dir?).to be(true)
      end
    end

    context "when current dir is a puzzle directory" do
      before { create(:location, :puzzle_dir, path: current_path) }

      it "returns false" do
        expect(in_event_dir?).to be(false)
      end
    end
  end

  describe "#in_puzzle_dir?" do
    subject(:in_puzzle_dir?) { target.in_puzzle_dir? }

    context "when current dir is neither an event nor a puzzle directory" do
      it "returns false" do
        expect(in_puzzle_dir?).to be(false)
      end
    end

    context "when current dir is an event directory" do
      before { create(:location, :year_dir, path: current_path) }

      it "returns false" do
        expect(in_puzzle_dir?).to be(false)
      end
    end

    context "when current dir is a puzzle directory" do
      before { create(:location, :puzzle_dir, path: current_path) }

      it "returns true" do
        expect(in_puzzle_dir?).to be(true)
      end
    end
  end
end
