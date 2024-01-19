module AocCli
  module Components
    class PuzzleSyncComponent < Kangaru::Component
      extend Forwardable

      include Helpers::ViewHelper

      attr_reader :log

      def_delegators :log, :puzzle

      def initialize(log:)
        @log = log
      end

      private

      def status_rows
        [
          [puzzle.presenter.puzzle_filename, log.puzzle_status],
          [puzzle.presenter.input_filename, log.input_status]
        ]
      end
    end
  end
end
