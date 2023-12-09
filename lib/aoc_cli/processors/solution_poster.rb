module AocCli
  module Processors
    class SolutionPoster < Core::Processor
      attr_accessor :year, :day, :answer

      validates :year, event_year: true
      validates :day, integer: { between: 1..25 }
      validates :answer, required: true

      def validate
        super
        validate_event_exists!        if errors.empty?
        validate_stats_exist!         if errors.empty?
        validate_puzzle_exists!       if errors.empty?
        validate_puzzle_not_complete! if errors.empty?
      end

      def run
        return unless valid?

        create_attempt!(post_solution!)
      end

      private

      def event
        @event ||= Event.first(year:)
      end

      def puzzle
        @puzzle ||= Puzzle.join(:events, id: :event_id).first(year:, day:)
      end

      def stats
        @stats ||= event&.stats || raise
      end

      def level
        @level ||= stats.current_level(day) || raise
      end

      def post_solution!
        Core::Repository.post_solution(year:, day:, level:, answer:)
      end

      def create_attempt!(data)
        Attempt.create(puzzle:, level:, answer:, **data)
      end

      def validate_event_exists!
        return unless event.nil?

        errors << Kangaru::Validation::Error.new(
          attribute: :event, message: "can't be blank"
        )
      end

      def validate_stats_exist!
        return unless event&.stats.nil?

        errors << Kangaru::Validation::Error.new(
          attribute: :stats, message: "can't be blank"
        )
      end

      def validate_puzzle_exists!
        return unless puzzle.nil?

        errors << Kangaru::Validation::Error.new(
          attribute: :puzzle, message: "can't be blank"
        )
      end

      def validate_puzzle_not_complete!
        return unless stats.complete?(day)

        errors << Kangaru::Validation::Error.new(
          attribute: :puzzle, message: "is already complete"
        )
      end
    end
  end
end
