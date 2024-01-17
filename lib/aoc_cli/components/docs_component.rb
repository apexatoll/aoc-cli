module AocCli
  module Components
    class DocsComponent < Kangaru::Component
      include Helpers::ViewHelper

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
            solve: "Submit and evaluate a puzzle solution",
            sync: "Ensure puzzle files are up to date",
            attempts: "Review previous attempts for the current puzzle"
          }
        }
      }.freeze

      def endpoints
        ENDPOINTS
      end

      def title
        "Advent of Code CLI"
      end

      def commands_table(commands, indent: 0)
        rows = commands.transform_keys(&:to_s).to_a

        table_for(*rows, gap: 4, indent:)
      end
    end
  end
end
