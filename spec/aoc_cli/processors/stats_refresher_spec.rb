RSpec.describe AocCli::Processors::StatsRefresher do
  subject(:stats) { create(:stats, **initial_stats) }

  let(:initial_stats) { { day_1: 2, day_2: 1 } }

  describe "#run!" do
    subject(:run_process) { described_class.run!(stats:) }

    context "when stats is nil" do
      let(:stats) { nil }

      include_examples :failed_process, errors: ["Stats can't be blank"]
    end

    context "when stats is not a Stats record" do
      let(:stats) { :foobar }

      include_examples :failed_process, errors: ["Stats has incompatible type"]
    end

    context "when stats is a Stats record" do
      before do
        stub_request(:get, stats_url(stats)).to_return(body: updated_stats)
      end

      let(:updated_stats) do
        wrap_in_html <<~HTML, tag: :pre
          <a class="calendar-day2 calendar-#{day_2_class_name}"></a>
          <a class="calendar-day1 calendar-verycomplete"></a>
        HTML
      end

      let(:day_2_class_name) do
        case day_2_progress
        when 1 then "complete"
        when 2 then "verycomplete"
        end
      end

      context "and cache is up to date" do
        let(:day_2_progress) { stats.day_2 }

        it "does not raise any errors" do
          expect { run_process }.not_to raise_error
        end

        it "requests the stats" do
          expect { run_process }.to request(stats_url(stats)).via(:get)
        end

        it "does not update the stats" do
          expect { run_process }.not_to change { stats.reload.values }
        end

        it "returns the stats" do
          expect(run_process).to eq(stats)
        end
      end

      context "and cache is out of date" do
        let(:day_2_progress) { stats.day_2 + 1 }

        it "does not raise any errors" do
          expect { run_process }.not_to raise_error
        end

        it "requests the stats" do
          expect { run_process }.to request(stats_url(stats)).via(:get)
        end

        it "updates the stats" do
          expect { run_process }.to change { stats.reload.day_2 }.from(1).to(2)
        end

        it "returns the stats" do
          expect(run_process).to eq(stats)
        end
      end
    end
  end
end
