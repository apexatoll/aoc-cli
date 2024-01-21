RSpec.describe AocCli::Processors::PuzzleInitialiser, :with_temp_dir do
  subject(:processor) { described_class.new(event:, day:) }

  let(:puzzle_dir) { temp_path(day.to_s) }

  let(:puzzle_url) { "https://adventofcode.com/#{event&.year}/day/#{day}" }

  let(:input_url) { "https://adventofcode.com/#{event&.year}/day/#{day}/input" }

  let(:content) { "Some content" }

  let(:input) { "Some input" }

  before do
    stub_request(:get, puzzle_url).to_return(body: wrap_in_html(content))
    stub_request(:get, input_url).to_return(body: input)
  end

  describe "validations" do
    context "when event is nil" do
      let(:event) { nil }

      context "and day is nil" do
        let(:day) { nil }

        include_examples :invalid, errors: [
          "Event can't be blank",
          "Day can't be blank"
        ]
      end

      context "and day is not an integer" do
        let(:day) { :foobar }

        include_examples :invalid, errors: [
          "Event can't be blank",
          "Day is not an integer"
        ]
      end

      context "and day is lower than 1" do
        let(:day) { 0 }

        include_examples :invalid, errors: [
          "Event can't be blank",
          "Day is too small"
        ]
      end

      context "and day is higher than 25" do
        let(:day) { 26 }

        include_examples :invalid, errors: [
          "Event can't be blank",
          "Day is too large"
        ]
      end
    end

    context "when event is present" do
      let!(:event) { create(:event, year:) }

      let(:year) { 2016 }

      context "and day is nil" do
        let(:day) { nil }

        include_examples :invalid, errors: ["Day can't be blank"]
      end

      context "and day is not an integer" do
        let(:day) { :foobar }

        include_examples :invalid, errors: ["Day is not an integer"]
      end

      context "and day is lower than 1" do
        let(:day) { 0 }

        include_examples :invalid, errors: ["Day is too small"]
      end

      context "and day is higher than 25" do
        let(:day) { 26 }

        include_examples :invalid, errors: ["Day is too large"]
      end

      context "and day is valid" do
        let(:day) { 20 }

        context "and event stats are not set" do
          include_examples :invalid, errors: [
            "Event stats can't be blank"
          ]
        end

        context "and event stats are set" do
          before { create(:stats, event:) }

          context "and event location is not set" do
            include_examples :invalid, errors: [
              "Event location can't be blank"
            ]
          end

          context "and event location is set" do
            let!(:event_location) do
              create(:location, :year_dir, event:, path: event_dir)
            end

            context "and event dir does not exist" do
              let(:event_dir) { temp_path("does-not-exist").to_s }

              include_examples :invalid, errors: [
                "Event dir does not exist"
              ]
            end

            context "and event dir exists" do
              let(:event_dir) { temp_dir }

              context "and puzzle dir already exists" do
                before { puzzle_dir.mkdir }

                include_examples :invalid, errors: [
                  "Puzzle dir already exists"
                ]
              end

              context "and puzzle dir does not already exist" do
                include_examples :valid
              end
            end
          end
        end
      end
    end
  end

  describe ".run!" do
    subject(:run_process) { described_class.run!(event:, day:) }

    let(:event) do
      create(:event, :with_location, :with_stats, path: temp_dir)
    end

    let(:day) { 20 }

    before do
      allow(AocCli::Processors::ProgressSyncer).to receive(:run!)
    end

    context "and puzzle is not already initialised elsewhere" do
      let(:puzzle)   { AocCli::Puzzle.last }
      let(:progress) { AocCli::Progress.last }
      let(:location) { AocCli::Location.last }

      it "fetches the puzzle content" do
        expect { run_process }.to request_url(puzzle_url).via(:get)
      end

      it "fetches the puzzle input" do
        expect { run_process }.to request_url(input_url).via(:get)
      end

      it "creates the Puzzle record" do
        expect { run_process }
          .to create_model(AocCli::Puzzle)
          .with_attributes(event:, day:, content:, input:)
      end

      it "syncs the puzzle progress" do
        run_process

        expect(AocCli::Processors::ProgressSyncer)
          .to have_received(:run!)
          .with(puzzle:, stats: event.stats)
      end

      it "creates the Location record" do
        expect { run_process }
          .to create_model(AocCli::Location)
          .with_attributes(path: puzzle_dir.to_s)
      end

      it "associates the progress to the puzzle" do
        run_process
        expect(puzzle.part_one_progress).to eq(progress)
      end

      it "associates the location to the puzzle" do
        run_process
        expect(puzzle.location).to eq(location)
      end

      it "returns the created Puzzle" do
        expect(run_process).to eq(puzzle)
      end
    end

    context "and puzzle is already initialised elsewhere" do
      let!(:puzzle) do
        create(
          :puzzle, :with_location,
          event:, day:,
          content: cached_content,
          input: cached_input
        )
      end

      context "and cached version is outdated" do
        let(:cached_content) { content.reverse }
        let(:cached_input)   { input.reverse }

        it "fetches the puzzle content" do
          expect { run_process }.to request_url(puzzle_url).via(:get)
        end

        it "fetches the puzzle input" do
          expect { run_process }.to request_url(input_url).via(:get)
        end

        it "does not create a Puzzle record" do
          expect { run_process }.not_to create_model(AocCli::Puzzle)
        end

        it "updates the Puzzle content and input" do
          expect { run_process }
            .to change { puzzle.reload.values }
            .to include(content:, input:)
        end

        it "syncs the puzzle progress" do
          run_process

          expect(AocCli::Processors::ProgressSyncer)
            .to have_received(:run!)
            .with(puzzle:, stats: event.stats)
        end

        it "does not create a Location record" do
          expect { run_process }.not_to create_model(AocCli::Location)
        end

        it "updates the Location record path" do
          expect { run_process }
            .to change { puzzle.reload.location.values }
            .to include(path: puzzle_dir.to_s)
        end

        it "returns the updated Puzzle" do
          expect(run_process.reload).to eq(puzzle.reload)
        end
      end

      context "and cached version is up to date" do
        let(:cached_content) { content }
        let(:cached_input)   { input }

        it "fetches the puzzle content" do
          expect { run_process }.to request_url(puzzle_url).via(:get)
        end

        it "fetches the puzzle input" do
          expect { run_process }.to request_url(input_url).via(:get)
        end

        it "does not create a Puzzle record" do
          expect { run_process }.not_to create_model(AocCli::Puzzle)
        end

        it "does not update the Puzzle" do
          expect { run_process }.not_to change { puzzle.reload.values }
        end

        it "syncs the puzzle progress" do
          run_process

          expect(AocCli::Processors::ProgressSyncer)
            .to have_received(:run!)
            .with(puzzle:, stats: event.stats)
        end

        it "does not create a Location record" do
          expect { run_process }.not_to create_model(AocCli::Location)
        end

        it "updates the Location record path" do
          expect { run_process }
            .to change { puzzle.reload.location.values }
            .to include(path: puzzle_dir.to_s)
        end

        it "returns the existing Puzzle" do
          expect(run_process).to eq(puzzle)
        end
      end
    end
  end
end
