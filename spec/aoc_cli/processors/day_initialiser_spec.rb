RSpec.describe AocCli::Processors::DayInitialiser, :with_temp_dir do
  subject(:day_initialiser) { described_class.new(**attributes) }

  let(:attributes) { { year:, day: }.compact }

  let(:year) { 2021 }

  let(:day) { 11 }

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
      let(:year) { 2044 }

      include_examples :invalid, errors: ["Year is in the future"]
    end

    context "when year is valid" do
      let(:year) { 2021 }

      context "and day is nil" do
        let(:day) { nil }

        include_examples :invalid, errors: ["Day can't be blank"]
      end

      context "and day is not an integer" do
        let(:day) { :foobar }

        include_examples :invalid, errors: ["Day is not an integer"]
      end

      context "and day is too low" do
        let(:day) { 0 }

        include_examples :invalid, errors: ["Day is too small"]
      end

      context "and day is too high" do
        let(:day) { 26 }

        include_examples :invalid, errors: ["Day is too large"]
      end

      context "and day is valid" do
        let(:day) { 21 }

        context "and event for specified year does not exist" do
          include_examples :invalid, errors: ["Event can't be blank"]
        end

        context "and event for specified year exists" do
          let!(:event) { create(:event, year:) }

          context "and event does not specify a location" do
            include_examples :invalid, errors: ["Event location can't be blank"]
          end

          context "and event specifies a location" do
            let!(:location) { create(:location, :year_dir, event:, path:) }

            context "and year dir does not exist" do
              let(:path) { temp_path("some-dir").to_s }

              include_examples :invalid, errors: ["Event dir does not exist"]
            end

            context "and year dir exists" do
              let(:path) { temp_dir.to_s }

              context "and puzzle dir already exists" do
                before { temp_path(day.to_s).mkdir }

                include_examples :invalid, errors: ["Puzzle dir already exists"]
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

  describe "#run" do
    subject(:run) { day_initialiser.run }

    let(:event) { create(:event, year:) }

    let!(:event_location) do
      create(:location, :year_dir, event:, path: event_dir)
    end

    let!(:puzzle) { create(:puzzle, event:, day:) }

    let(:event_dir)        { temp_dir.to_s }
    let(:puzzle_dir)       { temp_path(day.to_s).to_s }
    let(:puzzle_file_path) { File.join(puzzle_dir, "day_#{day}.md") }
    let(:input_file_path)  { File.join(puzzle_dir, "input") }

    before do
      allow(AocCli::Processors::PuzzleRefresher)
        .to receive(:run)
        .with(year:, day:)
        .and_return(puzzle)
    end

    context "when invalid" do
      before { temp_path(day.to_s).mkdir }

      it "does not refresh the puzzle" do
        run
        expect(AocCli::Processors::PuzzleRefresher).not_to have_received(:run)
      end

      it "does not create a Location record" do
        expect { run }.not_to create_model(AocCli::Location)
      end

      it "does not make the day directory" do
        expect { run }.not_to create_temp_dir(day.to_s)
      end

      it "does not write the puzzle file" do
        expect { run }
          .not_to create_temp_file(puzzle_file_path)
          .with_contents(puzzle.content)
      end

      it "does not write the input file" do
        expect { run }
          .not_to create_temp_file(input_file_path)
          .with_contents(puzzle.input)
      end

      it "returns nil" do
        expect(run).to be_nil
      end
    end

    context "when valid" do
      context "and puzzle location record already exists" do
        let!(:puzzle_location) { create(:location, :puzzle_dir, puzzle:) }

        it "refreshes the puzzle" do
          run

          expect(AocCli::Processors::PuzzleRefresher)
            .to have_received(:run)
            .with(year:, day:)
            .once
        end

        it "does not create a Location record" do
          expect { run }.not_to create_model(AocCli::Location)
        end

        it "updates the existing Location attributes" do
          run

          expect(puzzle_location.reload).to have_attributes(
            resource: puzzle, path: puzzle_dir
          )
        end

        it "makes the day directory" do
          expect { run }.to create_temp_dir(day.to_s)
        end

        it "writes the puzzle file" do
          expect { run }
            .to create_temp_file(puzzle_file_path)
            .with_contents(puzzle.content)
        end

        it "writes the input file" do
          expect { run }
            .to create_temp_file(input_file_path)
            .with_contents(puzzle.input)
        end

        it "returns the Puzzle record" do
          expect(run).to eq(puzzle)
        end
      end

      context "and puzzle location record does not already exist" do
        let(:puzzle_location) { AocCli::Location.last }

        it "refreshes the puzzle" do
          run

          expect(AocCli::Processors::PuzzleRefresher)
            .to have_received(:run)
            .with(year:, day:)
            .once
        end

        it "creates a Location record" do
          expect { run }.to create_model(AocCli::Location)
        end

        it "sets the expected Location attributes" do
          run

          expect(puzzle_location).to have_attributes(
            resource: puzzle, path: puzzle_dir
          )
        end

        it "makes the day directory" do
          expect { run }.to create_temp_dir(day.to_s)
        end

        it "writes the puzzle file" do
          expect { run }
            .to create_temp_file(puzzle_file_path)
            .with_contents(puzzle.content)
        end

        it "writes the input file" do
          expect { run }
            .to create_temp_file(input_file_path)
            .with_contents(puzzle.input)
        end

        it "returns the Puzzle record" do
          expect(run).to eq(puzzle)
        end
      end
    end
  end
end
