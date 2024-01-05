RSpec.describe AocCli::Processors::StatsInitialiser do
  describe ".run!" do
    subject(:run_process) { described_class.run!(event:) }

    context "when event is nil" do
      let(:event) { nil }

      include_examples :failed_process, errors: ["Event can't be blank"]
    end

    context "when event is not an Event record" do
      let(:event) { :event }

      include_examples :failed_process, errors: ["Event has incompatible type"]
    end

    context "when event is an Event record" do
      let(:event) { create(:event) }

      context "and stats have already been initialised" do
        before { create(:stats, event:) }

        include_examples :failed_process, errors: ["Stats already exist"]
      end

      context "and stats have not already been initialised" do
        before { stub_request(:get, stats_url(event)).to_return(body:) }

        let(:body) do
          wrap_in_html(<<~HTML, tag: :pre)
            <div class="calendar">#{progress_tags.join}</div>
          HTML
        end

        let(:progress_tags) do
          fetched_stats.map do |day, progress|
            <<~HTML
              <a class="#{day_class(day)} #{progress_class(progress)}"></a>
            HTML
          end
        end

        def day_class(day)
          "calendar-day#{day.to_s.delete_prefix('day_')}"
        end

        def progress_class(progress)
          case progress
          when 1 then "calendar-complete"
          when 2 then "calendar-verycomplete"
          end
        end

        shared_examples :initialises_stats do
          let(:stats) { AocCli::Stats.last }

          it "requests the stats" do
            expect { run_process }.to request_url(stats_url(event))
          end

          it "creates a Stats record" do
            expect { run_process }
              .to create_model(AocCli::Stats)
              .with_attributes(event:, **fetched_stats)
          end

          it "returns the Stats record" do
            expect(run_process).to eq(stats)
          end
        end

        context "and event is ongoing" do
          let(:fetched_stats) { { day_1: 2, day_2: 1, day_3: 0 } }

          include_examples :initialises_stats
        end

        context "and event is not ongoing" do
          let(:fetched_stats) do
            1.upto(25).to_h { |day| [:"day_#{day}", [0, 1, 2].sample] }
          end

          include_examples :initialises_stats
        end
      end
    end
  end
end
