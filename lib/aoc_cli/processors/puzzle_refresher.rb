module AocCli
  module Processors
    class PuzzleRefresher < Core::Processor
      attr_accessor :puzzle

      validates :puzzle, type: { equals: Puzzle }

      def run
        puzzle.update(content:, input:) || puzzle
      end

      private

      extend Forwardable

      def_delegators :puzzle, :year, :day

      def content
        Core::Repository.get_puzzle(year:, day:)
      end

      def input
        Core::Repository.get_input(year:, day:)
      end
    end
  end
end
