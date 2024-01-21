module AocCli
  module Processors
    class ProgressSyncer < Core::Processor
      attr_accessor :puzzle, :stats

      validates :puzzle, required: true
      validates :stats, required: true

      def run
        case current_progress
        when 0 then handle_not_complete!
        when 1 then handle_partially_complete!
        when 2 then handle_fully_complete!
        else raise
        end
      end

      private

      def_delegators :puzzle, :part_one_progress, :part_two_progress

      def current_progress
        stats.progress(puzzle.day)
      end

      def create_part_one_progress!
        Progress.create(puzzle:, level: 1, started_at: Time.now)
      end

      def create_part_two_progress!
        Progress.create(puzzle:, level: 2, started_at: Time.now)
      end

      def handle_not_complete!
        create_part_one_progress! if part_one_progress.nil?
      end

      def handle_partially_complete!
        part_one_progress&.complete! if part_one_progress&.incomplete?
        create_part_two_progress! if part_two_progress.nil?
      end

      def handle_fully_complete!
        part_two_progress&.complete! if part_two_progress&.incomplete?
      end
    end
  end
end
