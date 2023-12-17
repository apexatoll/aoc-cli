RSpec.describe AocCli::Presenters::StatsPresenter do
  subject(:presenter) { described_class.new(stats) }

  let(:stats) { create(:stats, day_1: 0, day_2: 1, day_3: 2) }

  describe "#progress_icons" do
    subject(:icons) { presenter.progress_icons(day) }

    context "when day is incomplete" do
      let(:day) { 1 }

      it "returns the expected_icons" do
        expect(icons).to eq(described_class::Icons::INCOMPLETE)
      end
    end

    context "when day is half complete" do
      let(:day) { 2 }

      it "returns the expected_icons" do
        expect(icons).to eq(described_class::Icons::HALF_COMPLETE)
      end
    end

    context "when day is complete" do
      let(:day) { 3 }

      it "returns the expected_icons" do
        expect(icons).to eq(described_class::Icons::COMPLETE)
      end
    end
  end

  describe "#total_progress" do
    subject(:total_progress) { presenter.total_progress }

    it "returns the expected string fraction" do
      expect(total_progress).to eq("#{stats.total}/50")
    end
  end
end
