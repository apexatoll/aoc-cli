RSpec.describe AocCli::PuzzleController, :with_temp_dir do
  around { |spec| Dir.chdir(temp_dir) { spec.run } }

  describe "/puzzle/init/:day" do
    subject(:make_request) { resolve path, params: }

    let(:path) { ["/puzzle/init", day].compact.join("/") }

    let(:params) { {} }

    let(:year) { 2023 }

    let(:day) { 2 }

    let(:puzzle_dir) { temp_path(day.to_s).to_s }

    shared_examples :does_not_initialise_puzzle do |options|
      let(:errors) { options[:errors] }

      it "does not create a Puzzle record" do
        expect { make_request }.not_to create_model(AocCli::Puzzle)
      end

      it "does not create a Location record" do
        expect { make_request }.not_to create_model(AocCli::Location)
      end

      it "does not create the puzzle dir" do
        expect { make_request }.not_to create_temp_dir(puzzle_dir)
      end

      it "does not render the default template" do
        expect { make_request }.not_to render_template(:init)
      end

      it "renders the expected errors" do
        expect { make_request }.to render_errors(*errors)
      end
    end

    shared_examples :initialises_new_puzzle do
      let(:puzzle) { AocCli::Puzzle.last }

      it "creates a Puzzle record" do
        expect { make_request }.to create_model(AocCli::Puzzle)
      end

      it "creates a Location record" do
        expect { make_request }.to create_model(AocCli::Location)
      end

      it "sets the expected Puzzle attributes" do
        make_request

        expect(puzzle).to have_attributes(
          event:, content: expected_content, input: expected_input
        )
      end

      it "sets the expected Location attributes" do
        make_request
        expect(puzzle.location).to have_attributes(path: puzzle_dir)
      end

      it "creates the puzzle dir" do
        expect { make_request }.to create_temp_dir(puzzle_dir)
      end

      it "creates the puzzle content file" do
        expect { make_request }
          .to create_temp_file(content_file)
          .with_contents(expected_content)
      end

      it "creates the puzzle input file" do
        expect { make_request }
          .to create_temp_file(input_file)
          .with_contents(expected_input)
      end

      it "renders the default template" do
        expect { make_request }.to render_template(:init)
      end
    end

    shared_examples :initialises_existing_puzzle do
      it "does not create a Puzzle record" do
        expect { make_request }.not_to create_model(AocCli::Puzzle)
      end

      it "does not create a Location record" do
        expect { make_request }.not_to create_model(AocCli::Location)
      end

      it "updates the existing Puzzle attributes" do
        expect { make_request }
          .to change { puzzle.reload.values }
          .to(include(content: expected_content, input: expected_input))
      end

      it "updates the existing Location path" do
        expect { make_request }
          .to change { puzzle.location.reload.path }
          .from(initial_dir)
          .to(puzzle_dir)
      end

      it "creates the puzzle dir" do
        expect { make_request }.to create_temp_dir(puzzle_dir)
      end

      it "creates the puzzle content file" do
        expect { make_request }
          .to create_temp_file(content_file)
          .with_contents(expected_content)
      end

      it "creates the puzzle input file" do
        expect { make_request }
          .to create_temp_file(input_file)
          .with_contents(expected_input)
      end

      it "renders the default template" do
        expect { make_request }.to render_template(:init)
      end
    end

    shared_examples :initialises_puzzle do
      let(:content_file)     { puzzle_content_path(dir: puzzle_dir, day:) }
      let(:input_file)       { puzzle_input_path(dir: puzzle_dir) }

      let(:expected_content) { puzzle_fixture(year:, day:) }
      let(:expected_input)   { input_fixture(year:, day:) }

      around { |spec| use_puzzle_cassette(year:, day:) { spec.run } }

      context "and puzzle has not been previously initialised" do
        include_examples :initialises_new_puzzle
      end

      context "and puzzle has been previously initialised" do
        let!(:puzzle) do
          create(:puzzle, :with_location, event:, day:, path: initial_dir)
        end

        before { Dir.mkdir(initial_dir) }

        context "and puzzle was previously initialised in current directory" do
          let(:initial_dir) { temp_path(day.to_s).to_s }

          include_examples :does_not_initialise_puzzle, errors: [
            "Puzzle dir already exists"
          ]
        end

        context "and puzzle was previously initialised elsewhere" do
          let(:initial_dir) do
            temp_path("some_dir").tap(&:mkdir).join(day.to_s).to_s
          end

          include_examples :initialises_existing_puzzle
        end
      end
    end

    context "when not in an event directory" do
      include_examples :does_not_initialise_puzzle, errors: [
        "Cannot perform that action from outside an event directory"
      ]
    end

    context "when in an event directory" do
      let!(:event) { create(:event, :with_location, year:, path: temp_dir) }

      context "and day is not specified" do
        let(:day) { nil }

        include_examples :does_not_initialise_puzzle, errors: [
          "Day can't be blank"
        ]
      end

      context "and day is valid" do
        let(:day) { 2 }

        include_examples :initialises_puzzle
      end
    end
  end
end
