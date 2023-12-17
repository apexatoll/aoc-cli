RSpec.describe AocCli::Stats do
  subject(:stats) { described_class.create(**attributes) }

  let(:attributes) { { event:, **stats_hash } }

  let(:event) { AocCli::Event.create(year: 2020) }

  let(:stats_hash) { 1.upto(25).to_h { |i| [:"day_#{i}", 0] } }

  describe "validations" do
    subject(:stats) { described_class.new(**attributes) }

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

  describe "#total" do
    subject(:total) { stats.total }

    let(:stats_hash) { super().merge(**progress) }

    context "when no progress has been made" do
      let(:progress) { {} }

      it "returns 0" do
        expect(total).to eq(0)
      end
    end

    context "when some progress has been made" do
      let(:progress) { { day_1: 2, day_3: 1, day_10: 2 } }

      it "returns the expected total" do
        expect(total).to eq(progress.values.sum)
      end
    end

    context "when event is complete" do
      let(:progress) do
        {
          day_1: 2,  day_2: 2,  day_3: 2,  day_4: 2,  day_5: 2,
          day_6: 2,  day_7: 2,  day_8: 2,  day_9: 2,  day_10: 2,
          day_11: 2, day_12: 2, day_13: 2, day_14: 2, day_15: 2,
          day_16: 2, day_17: 2, day_18: 2, day_19: 2, day_20: 2,
          day_21: 2, day_22: 2, day_23: 2, day_24: 2, day_25: 2
        }
      end

      it "returns 50" do
        expect(total).to eq(50)
      end
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

  describe "#advance_progress!" do
    subject(:advance_progress!) { stats.advance_progress!(day) }

    context "when day is not valid" do
      let(:day) { 100 }

      it "raises an error" do
        expect { advance_progress! }.to raise_error("invalid day")
      end
    end

    context "when day is valid" do
      let(:day) { 8 }

      let(:stats_hash) { super().merge("day_#{day}": progress) }

      context "and progress is initially 0" do
        let(:progress) { 0 }

        it "does not raise any errors" do
          expect { advance_progress! }.not_to raise_error
        end

        it "updates the progress" do
          expect { advance_progress! }
            .to change { stats.reload[:"day_#{day}"] }
            .from(0)
            .to(1)
        end
      end

      context "and progress is initially 1" do
        let(:progress) { 1 }

        it "does not raise any errors" do
          expect { advance_progress! }.not_to raise_error
        end

        it "updates the progress" do
          expect { advance_progress! }
            .to change { stats.reload[:"day_#{day}"] }
            .from(1)
            .to(2)
        end
      end

      context "and progress is initially 2" do
        let(:progress) { 2 }

        it "raises an error" do
          expect { advance_progress! }.to raise_error("already complete")
        end
      end
    end
  end
end
