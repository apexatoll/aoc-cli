RSpec.describe AocCli::Processors::PuzzleInitialiser, :with_temp_dir do
  describe ".run!" do
    subject(:run_process) { described_class.run!(event:, day:) }

    context "when event is nil" do
      let(:event) { nil }

      context "and day is nil" do
        let(:day) { nil }

        include_examples :failed_process, errors: [
          "Event can't be blank",
          "Day can't be blank"
        ]
      end

      context "and day is not an integer" do
        let(:day) { :foobar }

        include_examples :failed_process, errors: [
          "Event can't be blank",
          "Day is not an integer"
        ]
      end

      context "and day is lower than 1" do
        let(:day) { 0 }

        include_examples :failed_process, errors: [
          "Event can't be blank",
          "Day is too small"
        ]
      end

      context "and day is higher than 25" do
        let(:day) { 26 }

        include_examples :failed_process, errors: [
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

        include_examples :failed_process, errors: ["Day can't be blank"]
      end

      context "and day is not an integer" do
        let(:day) { :foobar }

        include_examples :failed_process, errors: ["Day is not an integer"]
      end

      context "and day is lower than 1" do
        let(:day) { 0 }

        include_examples :failed_process, errors: ["Day is too small"]
      end

      context "and day is higher than 25" do
        let(:day) { 26 }

        include_examples :failed_process, errors: ["Day is too large"]
      end

      context "and day is valid" do
        let(:day) { 20 }

        context "and event location is not set" do
          include_examples :failed_process, errors: [
            "Event location can't be blank"
          ]
        end

        context "and event location is set" do
          let!(:existing_location) do
            create(:location, :year_dir, event:, path: event_dir)
          end

          context "and event dir does not exist" do
            let(:event_dir) { temp_path("does-not-exist").to_s }

            include_examples :failed_process, errors: [
              "Event dir does not exist"
            ]
          end

          context "and event dir exists" do
            let(:event_dir) { temp_dir }

            let(:puzzle_dir) { temp_path(day.to_s) }

            context "and puzzle dir already exists" do
              before { puzzle_dir.mkdir }

              include_examples :failed_process, errors: [
                "Puzzle dir already exists"
              ]
            end

            context "and puzzle dir does not already exist" do
              let(:puzzle_url) do
                "https://adventofcode.com/#{year}/day/#{day}"
              end

              let(:input_url) do
                "https://adventofcode.com/#{year}/day/#{day}/input"
              end

              let(:content) { "Some content" }
              let(:input)   { "Some input" }

              before do
                stub_request(:get, puzzle_url)
                  .to_return(body: wrap_in_html(content))

                stub_request(:get, input_url)
                  .to_return(body: input)
              end

              context "and puzzle is not already initialised elsewhere" do
                let(:puzzle)   { AocCli::Puzzle.last }
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

                it "creates the Location record" do
                  expect { run_process }
                    .to create_model(AocCli::Location)
                    .with_attributes(path: puzzle_dir.to_s)
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

                  it "does not create a Location record" do
                    expect { run_process }.not_to create_model(AocCli::Location)
                  end

                  it "returns the updated Puzzle" do
                    expect(run_process).to eq(puzzle.reload)
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
                    expect { run_process }
                      .not_to change { puzzle.reload.values }
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
        end
      end
    end
  end
end
