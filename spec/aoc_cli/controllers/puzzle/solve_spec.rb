RSpec.describe "/puzzle/solve", :with_temp_dir do
  subject(:make_request) { resolve "/puzzle/solve", params: }

  let(:params) { { answer: } }

  let(:answer) { "123" }

  shared_examples :does_not_post_solution do |options|
    let(:errors) { options[:errors] }

    it "does not post the solution" do
      expect { make_request }.not_to request_url(
        %r{https://adventofcode.com/\d+/day/\d+/answer}
      ).via(:post)
    end

    it "does not create an Attempt record" do
      expect { make_request }.not_to create_model(AocCli::Attempt)
    end

    it "renders the expected errors" do
      expect { make_request }.to render_errors(*errors)
    end
  end

  shared_examples :posts_solution do
    include_context :puzzle_files_exist

    let(:current_puzzle) { "puzzle" }
    let(:current_input) { "input" }

    let(:level) { stats.current_level(day) }

    around do |spec|
      use_solution_cassette(year:, day:, level:, tag:) { spec.run }
    end

    context "and request was rate limited" do
      let(:tag) { :rate_limited }

      it "posts the solution" do
        expect { make_request }
          .to request_url(solution_url(puzzle))
          .via(:post)
      end

      it "creates an Attempt record" do
        expect { make_request }
          .to create_model(AocCli::Attempt)
          .with_attributes(status: :rate_limited, level:, answer:)
      end

      it "does not update the Stats" do
        expect { make_request }.not_to change { event.stats.reload.values }
      end

      it "does not update the Puzzle" do
        expect { make_request }.not_to change { puzzle.reload.values }
      end

      it "renders the expected message" do
        expect { make_request }.to output(<<~TEXT).to_stdout
          #{'Rate limited'.yellow.bold}: please wait 4 minutes.
        TEXT
      end
    end

    context "and answer was incorrect" do
      let(:tag) { :incorrect }

      it "posts the solution" do
        expect { make_request }
          .to request_url(solution_url(puzzle))
          .via(:post)
      end

      it "creates an Attempt record" do
        expect { make_request }
          .to create_model(AocCli::Attempt)
          .with_attributes(status: :incorrect, level:, answer:)
      end

      it "does not update the Stats" do
        expect { make_request }
          .not_to change { event.stats.reload.progress(day) }
      end

      it "does not update the Puzzle" do
        expect { make_request }.not_to change { puzzle.reload.values }
      end

      it "renders the expected message" do
        expect { make_request }.to output(<<~TEXT).to_stdout
          #{'Incorrect'.red.bold}: please wait 1 minutes.
        TEXT
      end
    end

    context "and answer was correct" do
      let(:tag) { :correct }

      let(:progress_record) do
        progress == 0 ? :part_one_progress : :part_two_progress
      end

      let(:updated_puzzle) { "updated puzzle content" }

      let(:updated_input) { "updated puzzle input" }

      before do
        stub_request(:get, puzzle_url(puzzle))
          .to_return(body: wrap_in_html(updated_puzzle))

        stub_request(:get, input_url(puzzle))
          .to_return(body: updated_input)
      end

      it "posts the solution" do
        expect { make_request }
          .to request_url(solution_url(puzzle))
          .via(:post)
      end

      it "creates an Attempt record" do
        expect { make_request }
          .to create_model(AocCli::Attempt)
          .with_attributes(status: :correct, level:, answer:)
      end

      it "updates the Stats" do
        expect { make_request }
          .to change { event.stats.reload.progress(day) }
          .by(1)
      end

      it "updates the Puzzle" do
        expect { make_request }
          .to change { puzzle.reload.send(progress_record).completed_at }
          .from(nil)
          .to(a_kind_of(Time))
      end

      it "requests the updated puzzle content" do
        expect { make_request }.to request_url(puzzle_url(puzzle))
      end

      it "requests the updated puzzle input" do
        expect { make_request }.to request_url(input_url(puzzle))
      end

      it "refreshes the puzzle file content" do
        expect { make_request }
          .to update_temp_file(puzzle_file)
          .to(updated_puzzle)
      end

      it "refreshes the input file content" do
        expect { make_request }
          .to update_temp_file(input_file)
          .to(updated_input)
      end

      it "renders the expected message" do
        expect { make_request }.to output(<<~TEXT).to_stdout
          #{'Correct'.green.bold}: part #{level} complete.
        TEXT
      end
    end
  end

  context "when not in an aoc directory" do
    include_examples :does_not_post_solution, errors: [
      "Action can't be performed outside puzzle directory"
    ]
  end

  context "when in an event dir" do
    before { create(:location, :year_dir, path: temp_dir) }

    include_examples :does_not_post_solution, errors: [
      "Action can't be performed outside puzzle directory"
    ]
  end

  context "when in a puzzle dir" do
    include_context :in_puzzle_dir, year: 2016, day: 2

    context "and answer is nil" do
      let(:answer) { nil }

      include_examples :does_not_post_solution, errors: [
        "Answer can't be blank"
      ]
    end

    context "and answer is present" do
      let(:answer) { "123" }

      context "and stats have not been initialised" do
        let(:stats) { nil }

        include_examples :does_not_post_solution, errors: [
          "Stats can't be blank"
        ]
      end

      context "and stats have been initialised" do
        let!(:stats) { create(:stats, event:, day_2: progress) }

        context "and puzzle is fully complete" do
          let(:progress) { 2 }

          include_examples :does_not_post_solution, errors: [
            "Puzzle is already complete"
          ]
        end

        context "and puzzle is partially complete" do
          let(:progress) { 1 }

          before { create(:progress, puzzle:, level: 2) }

          include_examples :posts_solution
        end

        context "and puzzle is not complete" do
          let(:progress) { 0 }

          before { create(:progress, puzzle:, level: 1) }

          include_examples :posts_solution
        end
      end
    end
  end
end
