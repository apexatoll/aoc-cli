RSpec.describe "/puzzle/sync", :with_temp_dir do
  subject(:make_request) { resolve "/puzzle/sync", params: }

  let(:params) { { skip_cache: }.compact }

  let(:skip_cache) { nil }

  shared_examples :does_not_request_puzzle do
    it "does not request the puzzle content" do
      expect { make_request }.not_to request_url(puzzle_url(puzzle))
    end

    it "does not request the puzzle input" do
      expect { make_request }.not_to request_url(input_url(puzzle))
    end
  end

  shared_examples :requests_puzzle do
    it "does not request the puzzle content" do
      expect { make_request }.to request_url(puzzle_url(puzzle))
    end

    it "does not request the puzzle input" do
      expect { make_request }.to request_url(input_url(puzzle))
    end
  end

  shared_examples :does_not_update_puzzle_record do
    it "does not update the puzzle record" do
      expect { make_request }.not_to change { puzzle.reload.values }
    end
  end

  shared_examples :updates_puzzle_record do
    it "updates the puzzle record" do
      expect { make_request }
        .to change { puzzle.reload.values }
        .to include(content: updated_puzzle, input: updated_input)
    end
  end

  shared_examples :creates_puzzle_files do
    it "creates the puzzle file" do
      expect { make_request }
        .to create_temp_file(puzzle_file)
        .with_contents { puzzle.reload.content }
    end

    it "creates the input file" do
      expect { make_request }
        .to create_temp_file(input_file)
        .with_contents { puzzle.reload.input }
    end

    it "renders the expected message" do
      expect { make_request }.to output(<<~TEXT).to_stdout
        Puzzle #{puzzle.presenter.date} refreshed
        Puzzle: new
        Input: new
      TEXT
    end
  end

  shared_examples :updates_puzzle_files do
    it "updates the puzzle file" do
      expect { make_request }
        .to update_temp_file(puzzle_file)
        .to { puzzle.reload.content }
    end

    it "updates the input file" do
      expect { make_request }
        .to update_temp_file(input_file)
        .to { puzzle.reload.input }
    end

    it "renders the expected message" do
      expect { make_request }.to output(<<~TEXT).to_stdout
        Puzzle #{puzzle.presenter.date} refreshed
        Puzzle: modified
        Input: modified
      TEXT
    end
  end

  shared_examples :skips_puzzle_files do
    it "does not update the puzzle file" do
      expect { make_request }.not_to update_temp_file(puzzle_file)
    end

    it "does not update the input file" do
      expect { make_request }.not_to update_temp_file(input_file)
    end

    it "renders the expected message" do
      expect { make_request }.to output(<<~TEXT).to_stdout
        Puzzle #{puzzle.presenter.date} refreshed
        Puzzle: unmodified
        Input: unmodified
      TEXT
    end
  end

  shared_examples :does_not_synchronise_puzzle do |options|
    let(:errors) { options[:errors] }

    it "renders the expected errors" do
      expect { make_request }.to render_errors(*errors)
    end
  end

  context "when not in an aoc directory" do
    include_examples :does_not_synchronise_puzzle, errors: [
      "Action can't be performed outside puzzle directory"
    ]
  end

  context "when in an event directory" do
    include_context :in_event_dir, year: 2020

    include_examples :does_not_synchronise_puzzle, errors: [
      "Action can't be performed outside puzzle directory"
    ]
  end

  context "when in a puzzle directory" do
    include_context :in_puzzle_dir, year: 2023, day: 2

    context "and skip_cache flag is not passed" do
      let(:skip_cache) { nil }

      context "and puzzle files do not initially exist" do
        include_examples :does_not_request_puzzle
        include_examples :does_not_update_puzzle_record
        include_examples :creates_puzzle_files
      end

      context "and puzzle files initially exist" do
        include_context :puzzle_files_exist

        context "and puzzle files do not match cached values" do
          let(:current_puzzle) { puzzle.content.reverse }
          let(:current_input)  { puzzle.input.reverse }

          include_examples :does_not_request_puzzle
          include_examples :does_not_update_puzzle_record
          include_examples :updates_puzzle_files
        end

        context "and puzzle files match cached values" do
          let(:current_puzzle) { puzzle.content }
          let(:current_input)  { puzzle.input }

          include_examples :does_not_request_puzzle
          include_examples :does_not_update_puzzle_record
          include_examples :skips_puzzle_files
        end
      end
    end

    context "and skip_cache flag is passed" do
      let(:skip_cache) { true }

      before do
        stub_request(:get, input_url(puzzle))
          .to_return(body: updated_input)

        stub_request(:get, puzzle_url(puzzle))
          .to_return(body: wrap_in_html(updated_puzzle))
      end

      context "and cached puzzle is up to date" do
        let(:updated_input)  { puzzle.input }
        let(:updated_puzzle) { puzzle.content }

        context "and puzzle files do not initially exist" do
          include_examples :requests_puzzle
          include_examples :does_not_update_puzzle_record
          include_examples :creates_puzzle_files
        end

        context "and puzzle files initially exist" do
          include_context :puzzle_files_exist

          context "and puzzle files do not match cached values" do
            let(:current_puzzle) { puzzle.content.reverse }
            let(:current_input)  { puzzle.input.reverse }

            include_examples :requests_puzzle
            include_examples :does_not_update_puzzle_record
            include_examples :updates_puzzle_files
          end

          context "and puzzle files match cached values" do
            let(:current_puzzle) { puzzle.content }
            let(:current_input)  { puzzle.input }

            include_examples :requests_puzzle
            include_examples :does_not_update_puzzle_record
            include_examples :skips_puzzle_files
          end
        end
      end

      context "and cached puzzle is not up to date" do
        let(:updated_input)  { "updated input" }
        let(:updated_puzzle) { "updated content" }

        context "and puzzle files do not initially exist" do
          include_examples :requests_puzzle
          include_examples :updates_puzzle_record
          include_examples :creates_puzzle_files
        end

        context "and puzzle files initially exist" do
          include_context :puzzle_files_exist

          context "and puzzle files do not match cached values" do
            let(:current_puzzle) { puzzle.content.reverse }
            let(:current_input)  { puzzle.input.reverse }

            include_examples :requests_puzzle
            include_examples :updates_puzzle_record
            include_examples :updates_puzzle_files
          end

          context "and puzzle files match cached values" do
            let(:current_puzzle) { puzzle.content }
            let(:current_input)  { puzzle.input }

            include_examples :requests_puzzle
            include_examples :updates_puzzle_record
            include_examples :updates_puzzle_files
          end
        end
      end
    end
  end
end
