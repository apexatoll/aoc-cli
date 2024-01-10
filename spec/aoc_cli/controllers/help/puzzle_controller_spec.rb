RSpec.describe "/help/puzzle/:action" do
  subject(:make_request) { resolve "/help/puzzle/#{action}", params: {} }

  shared_examples :renders_command_help do
    it "renders the expected help text" do
      expect { make_request }.to output(help).to_stdout
    end
  end

  describe ":init" do
    subject(:action) { :init }

    include_examples :renders_command_help do
      let(:help) do
        <<~TEXT
          aoc puzzle init

          Description:

            This command can only be run from an event directory (see event init).

            Initialises the given day's puzzle for the current event. This fetches
            the puzzle prompt and input from Advent of Code, creates a puzzle directory,
            and writes the puzzle files to it.

            Once initialised, the new puzzle directory contains two files:
            * Markdown puzzle prompt (format "day_<day>.md")
            * Plain text puzzle input (format "input")

            These files can be restored at any time using puzzle sync.

            The puzzle directory is a good place to write puzzle solution code and review
            previous solution attempts. See puzzle solve and puzzle attempts respectively

          Usage:

            aoc puzzle init <day>

            * <day>: Day of puzzle to initialise (1-25).

          Examples:

            aoc puzzle init 20 (in an event directory)

            Initializes the day 20 puzzle and creates puzzle directory

        TEXT
      end
    end
  end

  describe ":solve" do
    subject(:action) { :solve }

    include_examples :renders_command_help do
      let(:help) do
        <<~TEXT
          aoc puzzle solve

          Description:

            This command can only be run from a puzzle directory (see puzzle init).

            Posts the given answer to Advent of Code for the current puzzle. The response
            will have one of three possible states:

              1. Correct
              2. Incorrect
              3. Rate-limited

            If the attempt was correct, relevant stats are updated and the puzzle files
            are refreshed to include any new puzzle information.

            If the attempt was incorrect or rate-limited, the required wait time will be
            indicated to the nearest minute.

            Previous attempt data can be reviewed with the puzzle attempts command.

          Usage:

            aoc puzzle solve --answer=<answer>

            * <answer>: The puzzle solution to attempt

          Examples:

            aoc puzzle solve --answer abcdef (in a puzzle directory)

            Initializes the day 20 puzzle and creates puzzle directory

        TEXT
      end
    end
  end

  describe ":sync" do
    subject(:action) { :sync }

    include_examples :renders_command_help do
      let(:help) do
        <<~TEXT
          aoc puzzle sync

          Description:

            This command can only be run from a puzzle directory (see puzzle init).

            Restores puzzle dir files (puzzle and input) to their cached state.

            Puzzle data is cached when puzzles are initialised and correctly solved in
            order to decrease load on Advent of Code and increase performance. However
            there may be situations where the cache is outdated: for example if puzzles
            have been solved from the browser.

            To fetch and write the latest puzzle data, pass the --skip-cache flag.

          Usage:

            aoc puzzle sync [--skip-cache]

            * <skip-cache>: Whether to ignore puzzle file cache (default false)

          Examples:

            aoc puzzle sync (in a puzzle directory)

            Restores (writes or updates) puzzle files to cached state.


            aoc puzzle sync --skip-cache (in a puzzle directory)

            Puzzle data is refreshed before writing the puzzle files.

        TEXT
      end
    end
  end

  describe ":attempts" do
    subject(:action) { :attempts }

    include_examples :renders_command_help do
      let(:help) do
        <<~TEXT
          aoc puzzle attempts

          Description:

            This command can only be run from a puzzle directory (see puzzle init).

            Shows posted solution attempts for the current puzzle.

          Usage:

            aoc puzzle attempts

        TEXT
      end
    end
  end
end
