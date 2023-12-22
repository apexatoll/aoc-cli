RSpec.describe AocCli::Components::HelpComponent do
  subject(:help_component) { described_class.new }

  around do |spec|
    String.disable_colorization = true
    spec.run
    String.disable_colorization = false
  end

  describe "#render" do
    subject(:render) { help_component.render }

    let(:expected_text) do
      <<~TEXT

        Advent of Code CLI <#{AocCli::VERSION}>

        A command-line interface for the Advent of Code puzzles.

        Features include downloading puzzles and inputs, solving puzzles and
        tracking year progress from within the terminal.

        This is an unofficial project with no affiliation to Advent of Code.


          event

          Handle event directories

          Usage: aoc event <command>

            init        Create and initialise an event directory
            progress    Check your progress for the current event


          puzzle

          Handle puzzle directories

          Usage: aoc puzzle <command>

            init        Fetch and initialise puzzles for the current event
            solve       Submit and evaluate a puzzle solution
            sync        Ensure puzzle files are up to date
            attempts    Review previous attempts for the current puzzle

      TEXT
    end

    it "renders the expected text" do
      expect { render }.to output(expected_text).to_stdout
    end
  end
end
