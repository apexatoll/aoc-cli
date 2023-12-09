RSpec.describe AocCli::Stats do
  subject(:stats) { described_class.new(**attributes) }

  let(:attributes) { { event:, **stats_hash } }

  let(:event) { AocCli::Event.create(year: 2020) }

  let(:stats_hash) { 1.upto(25).to_h { |i| [:"day_#{i}", 0] } }

  describe "validations" do
    shared_examples :validates_day do |day|
      describe ":day_#{day}" do
        before { stats_hash.merge!("day_#{day}": value) }

        context "when nil" do
          let(:value) { nil }

          include_examples :invalid, errors: ["Day #{day} can't be blank"]
        end

        context "when not an integer" do
          let(:value) { :foobar }

          include_examples :invalid, errors: ["Day #{day} is not an integer"]
        end

        context "when 0" do
          let(:value) { 0 }

          include_examples :valid
        end

        context "when 1" do
          let(:value) { 1 }

          include_examples :valid
        end

        context "when 2" do
          let(:value) { 2 }

          include_examples :valid
        end

        context "when 3" do
          let(:value) { 3 }

          include_examples :invalid, errors: ["Day #{day} is too large"]
        end
      end
    end

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

    1.upto(25) do |day|
      include_examples :validates_day, day
    end
  end

  describe "#progress" do
    subject(:progress) { stats.progress(day) }

    context "when day is not valid" do
      let(:day) { 100 }

      it "raises an error" do
        expect { progress }.to raise_error("invalid day")
      end
    end

    context "when day is valid" do
      let(:day) { 3 }

      it "returns the stats value" do
        expect(progress).to eq(stats.day_3)
      end
    end
  end

  describe "#current_level" do
    subject(:level) { stats.current_level(day) }

    let(:day) { 10 }

    let(:stats_hash) { super().merge("day_#{day}": progress) }

    context "when day is not attempted" do
      let(:progress) { 0 }

      it "returns 1" do
        expect(level).to eq(1)
      end
    end

    context "when day is half complete" do
      let(:progress) { 1 }

      it "returns 2" do
        expect(level).to eq(2)
      end
    end

    context "when day is complete" do
      let(:progress) { 2 }

      it "returns nil" do
        expect(level).to be_nil
      end
    end
  end

  describe "#complete?" do
    subject(:complete?) { stats.complete?(day) }

    let(:day) { 1 }

    let(:stats_hash) { super().merge("day_#{day}": progress) }

    context "when day is not attempted" do
      let(:progress) { 0 }

      it "returns false" do
        expect(complete?).to be(false)
      end
    end

    context "when day is half complete" do
      let(:progress) { 1 }

      it "returns false" do
        expect(complete?).to be(false)
      end
    end

    context "when day is complete" do
      let(:progress) { 2 }

      it "returns true" do
        expect(complete?).to be(true)
      end
    end
  end
end
