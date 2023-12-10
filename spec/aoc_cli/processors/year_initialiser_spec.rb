RSpec.describe AocCli::Processors::YearInitialiser, :with_temp_dir do
  subject(:year_initialiser) { described_class.new(**attributes) }

  let(:attributes) { { year:, dir: } }

  let(:year) { 2020 }

  let(:dir) { temp_dir.to_s }

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
      let(:year) { 2040 }

      include_examples :invalid, errors: ["Year is in the future"]
    end

    context "when year is valid" do
      let(:year) { 2020 }

      context "and dir is nil" do
        let(:dir) { nil }

        include_examples :invalid, errors: ["Dir can't be blank"]
      end

      context "and dir does not exist" do
        let(:dir) { temp_path("does-not-exist").to_s }

        include_examples :invalid, errors: ["Dir does not exist"]
      end

      context "and dir exists" do
        let(:dir) { temp_dir.to_s }

        context "and year path already exists" do
          before { temp_path(year.to_s).mkdir }

          include_examples :invalid, errors: ["Year dir already exists"]
        end

        context "and year path does not already exist" do
          include_examples :valid
        end
      end
    end
  end

  describe "#run" do
    subject(:run) { year_initialiser.run }

    let(:year_dir) { temp_path(year.to_s).to_s }

    before do
      allow(AocCli::Processors::StatsRefresher).to receive(:run)
    end

    context "when invalid" do
      let(:year) { 2014 }

      it "does not create an Event record" do
        expect { run }.not_to change { AocCli::Event.count }
      end

      it "does not fetch the stats" do
        run
        expect(AocCli::Processors::StatsRefresher).not_to have_received(:run)
      end

      it "does not create a Location record" do
        expect { run }.not_to change { AocCli::Location.count }
      end

      it "does not create the year directory" do
        expect { run }.not_to create_temp_dir(year_dir)
      end
    end

    context "when valid" do
      let(:year) { 2015 }

      context "and event does not already exist" do
        let(:event)    { AocCli::Event.last }
        let(:location) { AocCli::Location.last }

        it "creates an Event record" do
          expect { run }.to change { AocCli::Event.count }.by(1)
        end

        it "sets the expected Event attributes" do
          run
          expect(event).to have_attributes(year:)
        end

        it "fetches the stats" do
          run

          expect(AocCli::Processors::StatsRefresher)
            .to have_received(:run)
            .with(year:)
            .once
        end

        it "creates a Location record" do
          expect { run }.to change { AocCli::Location.count }.by(1)
        end

        it "sets the expected Location attributes" do
          run

          expect(location).to have_attributes(
            path: year_dir, resource: event
          )
        end

        it "creates the year directory" do
          expect { run }.to create_temp_dir(year_dir)
        end

        it "returns the Event record" do
          expect(run).to eq(event)
        end
      end

      context "and event already exists" do
        let!(:event) { create(:event, year:) }

        context "and event location is set" do
          let!(:location) { create(:location, :year_dir, event:) }

          it "does not create an Event record" do
            expect { run }.not_to change { AocCli::Event.count }
          end

          it "does not update the Event attributes" do
            expect { run }.not_to change { event.reload.values }
          end

          it "fetches the stats" do
            run

            expect(AocCli::Processors::StatsRefresher)
              .to have_received(:run)
              .with(year:)
              .once
          end

          it "does not create a Location record" do
            expect { run }.not_to change { AocCli::Location.count }
          end

          it "updates the expected Location attributes" do
            run

            expect(location.reload).to have_attributes(
              path: year_dir, resource: event
            )
          end

          it "creates the year directory" do
            expect { run }.to create_temp_dir(year_dir)
          end

          it "returns the Event record" do
            expect(run).to eq(event)
          end
        end

        context "and event location is not already set" do
          let(:location) { AocCli::Location.last }

          it "does not create an Event record" do
            expect { run }.not_to change { AocCli::Event.count }
          end

          it "does not update the Event attributes" do
            expect { run }.not_to change { event.reload.values }
          end

          it "fetches the stats" do
            run

            expect(AocCli::Processors::StatsRefresher)
              .to have_received(:run)
              .with(year:)
              .once
          end

          it "creates a Location record" do
            expect { run }.to change { AocCli::Location.count }.by(1)
          end

          it "sets the expected Location attributes" do
            run

            expect(location).to have_attributes(
              path: year_dir, resource: event
            )
          end

          it "creates the year directory" do
            expect { run }.to create_temp_dir(year_dir)
          end

          it "returns the Event record" do
            expect(run).to eq(event)
          end
        end
      end
    end
  end
end
