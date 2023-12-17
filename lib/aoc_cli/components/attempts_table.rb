module AocCli
  module Components
    class AttemptsTable < Kangaru::Component
      attr_reader :puzzle

      def initialize(puzzle:)
        @puzzle = puzzle
      end

      def title
        "Advent of Code: #{puzzle.presenter.date}"
      end

      def headings
        %w[Answer Status Time Hint]
      end

      def rows
        [*level_one_rows, separator, *level_two_rows].compact
      end

      private

      def level_one_rows
        @level_one_rows ||= rows_for(level_one_attempts)
      end

      def separator
        return if level_one_rows.empty? || level_two_rows.empty?

        :separator
      end

      def level_two_rows
        @level_two_rows ||= rows_for(level_two_attempts)
      end

      def level_one_attempts
        puzzle.attempts_dataset.where(level: 1).order(:created_at).to_a
      end

      def level_two_attempts
        puzzle.attempts_dataset.where(level: 2).order(:created_at).to_a
      end

      def rows_for(attempts)
        attempts.map do |attempt|
          [
            attempt.answer,
            attempt.presenter.status,
            attempt.created_at,
            attempt.presenter.hint
          ]
        end
      end
    end
  end
end
