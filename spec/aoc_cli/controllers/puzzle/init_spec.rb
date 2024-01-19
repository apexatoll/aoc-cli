RSpec.describe "/puzzle/init/:day", :with_temp_dir do
  subject(:make_request) { resolve path, params: {} }

  let(:path) { ["/puzzle/init", day].compact.join("/") }

  let(:day) { nil }

  let(:puzzle_dir) { temp_path(day.to_s).to_s }

  shared_examples :does_not_initialise_puzzle do |options|
    let(:errors) { options[:errors] }

    it "does not request the puzzle content" do
      expect { make_request }.not_to request_url(
        %r{https://adventofcode.com/20\d{2}/day/\d{1,2}}
      )
    end

    it "does not request the puzzle input" do
      expect { make_request }.not_to request_url(
        %r{https://adventofcode.com/20\d{2}/day/\d{1,2}/input}
      )
    end

    it "does not create a Puzzle record" do
      expect { make_request }.not_to create_model(AocCli::Puzzle)
    end

    it "does not create a Location record" do
      expect { make_request }.not_to create_model(AocCli::Location)
    end

    it "does not create the puzzle dir" do
      expect { make_request }.not_to create_temp_dir(puzzle_dir)
    end

    it "renders the expected errors" do
      expect { make_request }.to render_errors(*errors)
    end
  end

  shared_examples :initialises_puzzle do
    let(:content)      { puzzle_fixture(year:, day:) }
    let(:content_file) { puzzle_content_path(dir: puzzle_dir, day:) }
    let(:input)        { input_fixture(year:, day:) }
    let(:input_file)   { puzzle_input_path(dir: puzzle_dir) }

    around { |spec| use_puzzle_cassette(year:, day:) { spec.run } }

    shared_examples :requests_puzzle do
      it "requests the puzzle content" do
        expect { make_request }.to request_url(
          "https://adventofcode.com/#{year}/day/#{day}"
        )
      end

      it "requests the puzzle input" do
        expect { make_request }.to request_url(
          "https://adventofcode.com/#{year}/day/#{day}/input"
        )
      end
    end

    shared_examples :creates_puzzle_files do
      it "creates the puzzle dir" do
        expect { make_request }.to create_temp_dir(puzzle_dir)
      end

      it "writes the puzzle file" do
        expect { make_request }
          .to create_temp_file(content_file)
          .with_contents(content)
      end

      it "writes the input file" do
        expect { make_request }
          .to create_temp_file(input_file)
          .with_contents(input)
      end
    end

    shared_examples :renders_init_message do
      it "renders the expected message" do
        expect { make_request }.to output(<<~TEXT).to_stdout
          Puzzle initialised
            event  #{year}
            day    #{day}
        TEXT
      end
    end

    context "and puzzle has not already been initialised" do
      let(:puzzle) { AocCli::Puzzle.last }

      include_examples :requests_puzzle
      include_examples :creates_puzzle_files
      include_examples :renders_init_message

      it "creates a Puzzle record" do
        expect { make_request }
          .to create_model(AocCli::Puzzle)
          .with_attributes(content:, input:)
      end

      it "sets the Puzzle location" do
        make_request
        expect(puzzle.location.path).to eq(puzzle_dir)
      end
    end

    context "and puzzle has already been initialised" do
      let!(:puzzle) { create(:puzzle, :with_location, event:, day:) }

      include_examples :requests_puzzle
      include_examples :creates_puzzle_files
      include_examples :renders_init_message

      it "does not create a Puzzle record" do
        expect { make_request }.not_to create_model(AocCli::Puzzle)
      end

      it "updates the existing Puzzle content and input" do
        expect { make_request }
          .to change { puzzle.reload.values }
          .to include(content:, input:)
      end

      it "updates the Puzzle location" do
        expect { make_request }
          .to change { puzzle.reload.location.path }
          .to(puzzle_dir)
      end
    end
  end

  context "when not in an Advent of Code directory" do
    include_examples :does_not_initialise_puzzle, errors: [
      "Action can't be performed outside event directory"
    ]
  end

  context "when in a puzzle directory" do
    include_context :in_puzzle_dir

    include_examples :does_not_initialise_puzzle, errors: [
      "Action can't be performed outside event directory"
    ]
  end

  context "when in an event directory" do
    include_context :in_event_dir, year: 2023

    context "and day is not specified" do
      let(:day) { nil }

      include_examples :does_not_initialise_puzzle, errors: [
        "Day can't be blank"
      ]
    end

    context "and day is valid" do
      let(:day) { 2 }

      context "and puzzle dir already exists" do
        before { Dir.mkdir(puzzle_dir) }

        include_examples :does_not_initialise_puzzle, errors: [
          "Puzzle dir already exists"
        ]
      end

      context "and puzzle dir does not exist" do
        include_examples :initialises_puzzle
      end
    end
  end
end
