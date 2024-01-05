RSpec.describe AocCli::Processors::EventInitialiser, :with_temp_dir do
  describe ".run!" do
    subject(:run_process) { described_class.run!(year:, dir:) }

    let(:year) { 2020 }

    let(:dir) { temp_dir }

    context "when year is nil" do
      let(:year) { nil }

      include_examples :failed_process, errors: ["Year can't be blank"]
    end

    context "when year is not an integer" do
      let(:year) { :foobar }

      include_examples :failed_process, errors: ["Year is not an integer"]
    end

    context "when year is before first AoC event" do
      let(:year) { 2014 }

      include_examples :failed_process, errors: [
        "Year is before first Advent of Code event (2015)"
      ]
    end

    context "when year is after most recent AoC event" do
      let(:year) { 2040 }

      include_examples :failed_process, errors: ["Year is in the future"]
    end

    context "when year is valid" do
      let(:year) { 2020 }

      context "and dir is nil" do
        let(:dir) { nil }

        include_examples :failed_process, errors: ["Dir can't be blank"]
      end

      context "and dir does not exist" do
        let(:dir) { temp_path("does-not-exist").to_s }

        include_examples :failed_process, errors: ["Dir does not exist"]
      end

      context "and dir exists" do
        let(:dir) { temp_dir.to_s }

        context "and event already intialised elsewhere" do
          let(:existing_event_dir) { temp_path("exists") }

          before do
            existing_event_dir.mkdir

            create(
              :event, :with_location,
              year:, path: existing_event_dir.to_s
            )
          end

          include_examples :failed_process, errors: [
            "Event already initialised"
          ]
        end

        context "and year is not already initialised elsewhere" do
          context "and event dir already exists" do
            before { temp_path(year.to_s).mkdir }

            include_examples :failed_process, errors: [
              "Event dir already exists"
            ]
          end

          context "and event dir does not already exist" do
            let(:event)    { AocCli::Event.last }
            let(:stats)    { AocCli::Stats.last }
            let(:location) { AocCli::Location.last }

            let(:stats_data) { { day_1: 2, day_2: 2, day_3: 1 } }

            let(:event_dir) { temp_path(year.to_s).to_s }

            before do
              allow(AocCli::Core::Repository)
                .to receive(:get_stats)
                .and_return(stats_data)
            end

            it "creates an Event record" do
              expect { run_process }
                .to create_model(AocCli::Event)
                .with_attributes(year:)
            end

            it "creates a Stats record" do
              expect { run_process }
                .to create_model(AocCli::Stats)
                .with_attributes(**stats_data)
            end

            it "creates a Location record" do
              expect { run_process }
                .to create_model(AocCli::Location)
                .with_attributes(path: event_dir)
            end

            it "associates the Stats to the Event" do
              run_process
              expect(event.stats).to eq(stats)
            end

            it "associates the Location to the Event" do
              run_process
              expect(event.location).to eq(location)
            end

            it "creates the event directory" do
              expect { run_process }.to create_temp_dir(year.to_s)
            end

            it "returns the created Event record" do
              expect(run_process).to eq(event)
            end
          end
        end
      end
    end
  end
end
