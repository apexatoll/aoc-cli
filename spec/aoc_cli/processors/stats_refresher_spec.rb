RSpec.describe AocCli::Processors::StatsRefresher do
  subject(:stats_refresher) { described_class.new(**attributes) }

  let(:attributes) { { year: }.compact }

  describe "validations" do
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

      context "and event does not exist" do
        include_examples :invalid, errors: ["Event can't be blank"]
      end

      context "and event exists" do
        before { create(:event, year:) }

        include_examples :valid
      end
    end
  end

  describe "#run" do
    subject(:run) { stats_refresher.run }

    let(:year) { 2015 }

    let(:stats_url) { "https://adventofcode.com/#{year}" }

    let(:new_stats) do
      {
        day_1: 2,  day_2: 2,  day_3: 1,  day_4: 0,  day_5: 2,
        day_6: 0,  day_7: 1,  day_8: 0,  day_9: 2,  day_10: 0,
        day_11: 2, day_12: 2, day_13: 2, day_14: 0, day_15: 1,
        day_16: 2, day_17: 1, day_18: 0, day_19: 2, day_20: 0,
        day_21: 2, day_22: 1, day_23: 2, day_24: 0, day_25: 0
      }
    end

    before do
      allow(AocCli::Core::Repository)
        .to receive(:get_stats)
        .with(year:)
        .and_return(new_stats)
    end

    context "when invalid" do
      it "does not fetch the stats" do
        run

        expect(AocCli::Core::Repository)
          .not_to have_received(:get_stats)
          .with(year:)
      end

      it "does not create a Stats record" do
        expect { run }.not_to change { AocCli::Stats.count }
      end

      it "returns nil" do
        expect(run).to be_nil
      end
    end

    context "when valid" do
      let!(:event) { create(:event, year:) }

      context "and stats do not already exist" do
        let(:stats) { AocCli::Stats.last }

        it "fetches the stats" do
          run

          expect(AocCli::Core::Repository)
            .to have_received(:get_stats)
            .with(year:)
            .once
        end

        it "creates a Stats record" do
          expect { run }.to change { AocCli::Stats.count }.by(1)
        end

        it "sets the expected Stats attributes" do
          run
          expect(stats).to have_attributes(event:, **new_stats)
        end

        it "returns the Stats record" do
          expect(run).to eq(stats)
        end
      end

      context "and stats already exist" do
        let!(:stats) { create(:stats, event:) }

        it "fetches the stats" do
          run

          expect(AocCli::Core::Repository)
            .to have_received(:get_stats)
            .with(year:)
            .once
        end

        it "does not create a Stats record" do
          expect { run }.not_to change { AocCli::Stats.count }
        end

        it "updates the existing Stats record" do
          expect { run }
            .to change { stats.reload.values }
            .to(include(new_stats))
        end

        it "returns the Stats record" do
          expect(run.reload).to eq(stats.reload)
        end
      end
    end
  end
end
