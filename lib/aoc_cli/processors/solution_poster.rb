module AocCli
  module Processors
    class SolutionPoster < Core::Processor
      attr_accessor :puzzle, :answer

      validates :puzzle, type: { equals: Puzzle }

      validates :answer, required: true

      # TODO: replace with conditional validation
      def validate
        super
        validate_puzzle_location_set! if errors.empty?
        validate_stats_associated! if errors.empty?
        validate_puzzle_not_complete! if errors.empty?
      end

      def run
        create_attempt!(post_solution!).tap do |attempt|
          advance_puzzle! if attempt.correct?
        end
      end

      private

      def_delegators :puzzle, :event, :location, :year, :day

      def level
        @level ||= event.stats.current_level(day) || raise
      end

      def post_solution!
        Core::Repository.post_solution(year:, day:, level:, answer:)
      end

      def create_attempt!(response)
        Attempt.create(puzzle:, level:, answer:, **response)
      end

      def advance_puzzle!
        event.stats.advance_progress!(day)

        ProgressSyncer.run!(puzzle:, stats: event.stats.reload)
        PuzzleDirSynchroniser.run!(puzzle:, location:, skip_cache: true)
      end

      def validate_puzzle_location_set!
        return unless location.nil?

        errors << Kangaru::Validation::Error.new(
          attribute: :location, message: "can't be blank"
        )
      end

      def validate_stats_associated!
        return unless puzzle.event.stats.nil?

        errors << Kangaru::Validation::Error.new(
          attribute: :stats, message: "can't be blank"
        )
      end

      def validate_puzzle_not_complete!
        return unless event.stats.complete?(day)

        errors << Kangaru::Validation::Error.new(
          attribute: :puzzle, message: "is already complete"
        )
      end
    end
  end
end
