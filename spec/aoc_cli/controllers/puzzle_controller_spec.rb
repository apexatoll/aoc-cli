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

  describe "/puzzle/solve" do
    subject(:make_request) { resolve "/puzzle/solve", params: }

    let(:params) { { answer: }.compact }

    let(:year) { 2016 }

    let(:day) { 2 }

    let(:answer) { "abc" }

    let(:progress) { 0 }

    let(:level) { stats.current_level(day) }

    let!(:event) { create(:event, year:) }

    let!(:stats) { create(:stats, event:, day_2: progress) }

    let(:attempt) { AocCli::Attempt.last }

    let(:tag) { nil }

    around do |spec|
      use_solution_cassette(year:, day:, level:, tag:) { spec.run }
    end

    shared_examples :does_not_post_solution do |options|
      let(:errors) { options[:errors] }

      it "does not create an Attempt record" do
        expect { make_request }.not_to create_model(AocCli::Attempt)
      end

      it "does not update the Stats" do
        expect { make_request }.not_to change { stats.reload.values }
      end

      it "renders the expected errors" do
        expect { make_request }.to render_errors(*errors)
      end

      it "does not update the puzzle" do
        expect { make_request }.not_to change { puzzle.reload.values }
      end
    end

    shared_examples :posts_solution do
      shared_examples :handles_rate_limited_request do
        let(:attempt) { AocCli::Attempt.last }

        it "creates an Attempt record" do
          expect { make_request }.to create_model(AocCli::Attempt)
        end

        it "sets the expected Attempt attributes" do
          make_request

          expect(attempt).to have_attributes(
            status: :rate_limited, level:, answer:
          )
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

      shared_examples :handles_incorrect_answer do
        let(:attempt) { AocCli::Attempt.last }

        it "creates an Attempt record" do
          expect { make_request }.to create_model(AocCli::Attempt)
        end

        it "sets the expected Attempt attributes" do
          make_request

          expect(attempt).to have_attributes(
            status: :incorrect, level:, answer:
          )
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

      shared_examples :handles_correct_answer do
        let(:attempt) { AocCli::Attempt.last }

        let(:puzzle_timestamp) do
          progress == 0 ? :part_one_completed_at : :part_two_completed_at
        end

        it "creates an Attempt record" do
          expect { make_request }.to create_model(AocCli::Attempt)
        end

        it "sets the expected Attempt attributes" do
          make_request

          expect(attempt).to have_attributes(
            status: :correct, level:, answer:
          )
        end

        it "updates the Stats" do
          expect { make_request }
            .to change { event.stats.reload.progress(day) }
            .by(1)
        end

        it "updates the Puzzle" do
          expect { make_request }
            .to change { puzzle.reload[puzzle_timestamp] }
            .from(nil)
            .to(a_kind_of(Time))
        end

        it "renders the expected message" do
          expect { make_request }.to output(<<~TEXT).to_stdout
            #{'Correct'.green.bold}: part #{level} complete.
          TEXT
        end
      end

      context "when the request was rate limited" do
        let(:tag) { :rate_limited }

        include_examples :handles_rate_limited_request
      end

      context "when the answer was incorrect" do
        let(:tag) { :incorrect }

        include_examples :handles_incorrect_answer
      end

      context "when the answer was correct" do
        let(:tag) { :correct }

        include_examples :handles_correct_answer
      end
    end

    context "when not in a puzzle dir" do
      let!(:puzzle) do
        create(:puzzle, event:, day:)
      end

      include_examples :does_not_post_solution, errors: [
        "Cannot perform that action from outside a puzzle directory"
      ]
    end

    context "when in a puzzle dir" do
      let!(:puzzle) do
        create(:puzzle, :with_location, event:, day:, path: temp_dir)
      end

      context "and no answer is specified" do
        let(:answer) { nil }

        include_examples :does_not_post_solution, errors: [
          "Answer can't be blank"
        ]
      end

      context "and answer is specified" do
        let(:answer) { "abc" }

        context "and the puzzle is fully complete" do
          let(:progress) { 2 }

          include_examples :does_not_post_solution, errors: [
            "Puzzle is already complete"
          ]
        end

        context "and the puzzle is half complete" do
          let(:progress) { 1 }

          include_examples :posts_solution
        end

        context "and the puzzle is not complete" do
          let(:progress) { 0 }

          include_examples :posts_solution
        end
      end
    end
  end

  describe "/puzzle/sync" do
    subject(:make_request) { resolve "/puzzle/sync", params: }

    let(:params) { { skip_cache: }.compact }

    let(:skip_cache) { nil }

    let(:year) { 2019 }

    let(:day) { 8 }

    let!(:puzzle) { create(:puzzle, :with_location, year:, day:, path:) }

    let(:puzzle_url) { "https://adventofcode.com/#{year}/day/#{day}" }

    let(:input_url) { "#{puzzle_url}/input" }

    let(:puzzle_file) { puzzle_content_path(day:, dir: temp_dir) }

    let(:input_file) { puzzle_input_path(dir: temp_dir) }

    shared_examples :does_not_request_puzzle do
      it "does not request the puzzle" do
        make_request
        assert_not_requested(:get, puzzle_url)
      end

      it "does not request the input" do
        make_request
        assert_not_requested(:get, input_url)
      end
    end

    shared_examples :requests_puzzle do
      it "requests the puzzle" do
        make_request
        assert_requested(:get, puzzle_url)
      end

      it "requests the input" do
        make_request
        assert_requested(:get, input_url)
      end
    end

    context "when not in puzzle directory" do
      let(:path) { temp_path("some-other-path").to_s }

      include_examples :does_not_request_puzzle

      it "renders the expected errors" do
        expect { make_request }.to render_errors(
          "Cannot perform that action from outside a puzzle directory"
        )
      end

      it "does not create a puzzle file" do
        expect { make_request }.not_to create_temp_file(puzzle_file)
      end

      it "does not create an input file" do
        expect { make_request }.not_to create_temp_file(input_file)
      end
    end

    context "when in puzzle directory" do
      let(:path) { temp_dir }

      before do
        puzzle_file.write(current_puzzle) if current_puzzle
        input_file.write(current_input) if current_input
      end

      shared_examples :renders_log do |options|
        let(:status) { options[:status] }

        it "does not render any errors" do
          expect { make_request }.not_to render_errors
        end

        it "renders the log" do
          expect { make_request }.to output(<<~TEXT).to_stdout
            Puzzle #{puzzle.presenter.date} synchronised
            \u2022 Puzzle file: #{status}
            \u2022 Input file: #{status}
          TEXT
        end
      end

      context "and cache is used" do
        let(:skip_cache) { nil }

        context "and files do not currently exist" do
          let(:current_puzzle) { nil }
          let(:current_input)  { nil }

          include_examples :does_not_request_puzzle

          include_examples :renders_log, status: :new

          it "creates the puzzle file from cache" do
            expect { make_request }
              .to create_temp_file(puzzle_file)
              .with_contents(puzzle.content)
          end

          it "creates the input file from cache" do
            expect { make_request }
              .to create_temp_file(input_file)
              .with_contents(puzzle.input)
          end
        end

        context "and current files have drifted from cache" do
          let(:current_puzzle) { puzzle.content.reverse }
          let(:current_input) { puzzle.input.reverse }

          include_examples :does_not_request_puzzle

          include_examples :renders_log, status: :modified

          it "updates the puzzle file from cache" do
            expect { make_request }
              .to update_temp_file(puzzle_file)
              .to(puzzle.content)
          end

          it "updates the input file from cache" do
            expect { make_request }
              .to update_temp_file(input_file)
              .to(puzzle.input)
          end

          it "does not render errors" do
            expect { make_request }.not_to render_errors
          end
        end

        context "and current files are same as cache" do
          let(:current_puzzle) { puzzle.content }
          let(:current_input) { puzzle.input }

          include_examples :does_not_request_puzzle

          include_examples :renders_log, status: :unmodified

          it "does not update the puzzle file" do
            expect { make_request }.not_to update_temp_file(puzzle_file)
          end

          it "does not update the input file" do
            expect { make_request }.not_to update_temp_file(input_file)
          end

          it "does not render errors" do
            expect { make_request }.not_to render_errors
          end
        end
      end

      context "and cache is not used" do
        let(:skip_cache) { true }

        let(:puzzle_html) do
          <<~HTML
            <html>
              <head></head>
              <body>
                <main>
                  <article>#{new_puzzle}</article>
                </main>
              </body>
            </html>
          HTML
        end

        before do
          stub_request(:get, puzzle_url).to_return(body: puzzle_html)
          stub_request(:get, input_url).to_return(body: new_input)
        end

        context "and files do not currently exist" do
          let(:current_puzzle) { nil }
          let(:current_input) { nil }

          context "and cache is still accurate" do
            let(:new_puzzle) { puzzle.content }
            let(:new_input) { puzzle.input }

            include_examples :requests_puzzle

            include_examples :renders_log, status: :new

            it "does not update the puzzle record" do
              expect { make_request }.not_to change { puzzle.reload.values }
            end

            it "creates the puzzle file" do
              expect { make_request }
                .to create_temp_file(puzzle_file)
                .with_contents(new_puzzle)
            end

            it "creates the input file" do
              expect { make_request }
                .to create_temp_file(input_file)
                .with_contents(new_input)
            end

            it "does not render errors" do
              expect { make_request }.not_to render_errors
            end
          end

          context "and cache is outdated" do
            let(:new_puzzle) { puzzle.content.reverse }
            let(:new_input) { puzzle.input.reverse }

            include_examples :requests_puzzle

            include_examples :renders_log, status: :new

            it "updates the puzzle record" do
              expect { make_request }
                .to change { puzzle.reload.values }
                .to(include(content: new_puzzle, input: new_input))
            end

            it "creates the puzzle file" do
              expect { make_request }
                .to create_temp_file(puzzle_file)
                .with_contents(new_puzzle)
            end

            it "creates the input file" do
              expect { make_request }
                .to create_temp_file(input_file)
                .with_contents(new_input)
            end

            it "does not render errors" do
              expect { make_request }.not_to render_errors
            end
          end
        end

        context "and files currently exist" do
          let(:current_puzzle) { puzzle.content }
          let(:current_input) { puzzle.input }

          context "and cache is still accurate" do
            let(:new_puzzle) { current_puzzle }
            let(:new_input) { current_input }

            include_examples :requests_puzzle

            include_examples :renders_log, status: :unmodified

            it "does not update the puzzle record" do
              expect { make_request }.not_to change { puzzle.reload.values }
            end

            it "does not update the puzzle file" do
              expect { make_request }.not_to update_temp_file(puzzle_file)
            end

            it "does not update the input file" do
              expect { make_request }.not_to update_temp_file(input_file)
            end

            it "does not render errors" do
              expect { make_request }.not_to render_errors
            end
          end

          context "and cache is outdated" do
            let(:new_puzzle) { puzzle.content.reverse }
            let(:new_input) { puzzle.input.reverse }

            include_examples :requests_puzzle

            include_examples :renders_log, status: :modified

            it "updates the puzzle record" do
              expect { make_request }
                .to change { puzzle.reload.values }
                .to(include(content: new_puzzle, input: new_input))
            end

            it "updates the puzzle file" do
              expect { make_request }
                .to update_temp_file(puzzle_file)
                .to(new_puzzle)
            end

            it "creates the input file" do
              expect { make_request }
                .to update_temp_file(input_file)
                .to(new_input)
            end

            it "does not render errors" do
              expect { make_request }.not_to render_errors
            end
          end
        end
      end
    end
  end

  describe "/puzzle/attempts" do
    subject(:make_request) { resolve "/puzzle/attempts", params: {} }

    context "when not in a puzzle dir" do
      it "renders the expected error" do
        expect { make_request }.to render_errors(
          "Cannot perform that action from outside a puzzle directory"
        )
      end

      it "does not render the attempts table" do
        expect { make_request }
          .not_to render_component(AocCli::Components::AttemptsTable)
      end
    end

    context "when in a puzzle dir" do
      let(:event)   { create(:event, :with_stats) }
      let!(:puzzle) { create(:puzzle, :with_location, event:, path: temp_dir) }

      it "does not render errors" do
        expect { make_request }.not_to render_errors
      end

      it "renders the attempts table" do
        expect { make_request }
          .to render_component(AocCli::Components::AttemptsTable)
          .with(puzzle:)
      end
    end
  end
end
