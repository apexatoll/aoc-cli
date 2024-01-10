RSpec.describe "/help/event/:action" do
  subject(:make_request) { resolve "/help/event/#{action}", params: {} }

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
          aoc event init

          Description:

            Initializes the event for the specified year by fetching event stats and
            creating an event directory in the target directory. The target directory
            defaults to the current directory but can be explicitly specified with the
            optional --dir String argument.

            The event directory serves as the location of event puzzle directories. For
            more information, refer to puzzle init. The name of the created event
            directory defaults to the event year.

            This command cannot be executed from, or target, a directory that is already
            managed by aoc (i.e., existing event and puzzle directories).

            The command will fail if the event has already been initialized elsewhere. To
            move an existing event's location, see the event attach command.

          Usage:

            aoc event init <year> [--dir=<dir>]

            * <year>: Year of the event to initialize.
            * <dir>: Base directory to initialize the event within (default ".").

          Examples:

            aoc event init 2023 (in a non-AoC directory)

            Initializes the 2023 event and creates the 2023 event directory inside the
            current directory.

            aoc event init 2023 --dir /foo/bar/aoc

            Initializes the 2023 event and creates the 2023 event directory in the
            specified directory.

        TEXT
      end
    end
  end

  describe ":attach" do
    subject(:action) { :attach }

    include_examples :renders_command_help do
      let(:help) do
        <<~TEXT
          aoc event attach

          Description:

            Attaches an existing event to the specified directory (defaults to current
            directory). This may be useful if the original directories have been moved
            or deleted.

            This command cannot be executed from, or target, a directory that is already
            managed by aoc (i.e., existing event and puzzle directories).

            The command will fail if the event has not already been initialized. To
            create a new event, see the event init command.

          Usage:

            aoc event attach <year> [--dir=<dir>]

            * <year>: Year of the event to relocate.
            * <dir>: The new event directory (default ".").

          Examples:

            aoc event attach 2023 (in a non-AoC directory)

            Relocates the 2023 event directory to the current directory


            aoc event attach 2023 --dir /foo/bar/aoc

            Relocates the 2023 event directory to the specified directory.

        TEXT
      end
    end
  end

  describe ":progress" do
    subject(:action) { :progress }

    include_examples :renders_command_help do
      let(:help) do
        <<~TEXT
          aoc event progress

          Description:

            Prints a table displaying progress (stars) for the current event.

            This command can be run from both event and puzzle directories.

          Usage:

            aoc event progress

        TEXT
      end
    end
  end
end
