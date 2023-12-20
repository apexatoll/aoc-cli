module AocCli
  module Presenters
    class PuzzlePresenter
      attr_reader :puzzle

      def initialize(puzzle)
        @puzzle = puzzle
      end

      def date
        "#{puzzle.event.year}-12-#{formatted_day}"
      end

      def puzzle_filename
        "day_#{formatted_day}.md"
      end

      def input_filename
        "input"
      end

      private

      def formatted_day
        puzzle.day.to_s.rjust(2, "0")
      end
    end
  end
end
