RSpec.describe AocCli::Core::StatsParser do
  subject(:stats_parser) { described_class.new(calendar_html) }

  let(:calendar_html) do
    <<~HTML
      <pre>
        <a class="calendar-day3"></a>
        <a class="calendar-day2 calendar-complete"></a>
        <a class="calendar-day1 calendar-verycomplete"></a>
      </pre>
    HTML
  end

  describe "#to_h" do
    subject(:stats) { stats_parser.to_h }

    let(:stat) { stats[:"day_#{day}"] }

    it "returns a hash" do
      expect(stats).to be_a(Hash)
    end

    it "sets the expected day keys" do
      expect(stats.keys).to include(:day_1, :day_2, :day_3)
    end

    it "sets integer values" do
      expect(stats.values).to all be_an(Integer)
    end

    context "when both parts of puzzle have been completed" do
      let(:day) { 1 }

      it "has a value of 2" do
        expect(stat).to eq(2)
      end
    end

    context "when the first part of puzzle has been completed" do
      let(:day) { 2 }

      it "has a value of 1" do
        expect(stat).to eq(1)
      end
    end

    context "when neither parts of puzzle have been completed" do
      let(:day) { 3 }

      it "has a value of 0" do
        expect(stat).to eq(0)
      end
    end
  end
end
