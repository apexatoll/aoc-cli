module AocCli
  module Components
    class HelpComponent < Kangaru::Component
      ENDPOINTS = {
        event: {
          description: "Handle event directories",
          commands: {
            init: "Create and initialise an event directory",
            progress: "Check your progress for the current event"
          }
        },

        puzzle: {
          description: "Handle puzzle directories",
          commands: {
            init: "Fetch and initialise puzzles for the current event",
            attempts: "Review previous attempts for the current puzzle"
          }
        }
      }.freeze

      def endpoints
        ENDPOINTS
      end

      def heading(text)
        text.to_s.bold.cyan
      end

      def title
        "Advent of Code CLI"
      end

      def commands_table(commands, indent: 0)
        commands.map do |command, description|
          format_command_row(command.to_s, description, indent:)
        end.join("\n").concat("\n")
      end

      private

      COMMAND_COLUMN_WIDTH = 12

      def format_command_row(command, description, indent:)
        padding = COMMAND_COLUMN_WIDTH - command.length

        [space(indent), command.cyan, space(padding), description].join
      end

      def space(size)
        " " * size
      end
    end
  end
end
