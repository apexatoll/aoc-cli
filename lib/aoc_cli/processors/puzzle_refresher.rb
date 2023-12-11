module AocCli
  module Processors
    class PuzzleRefresher < Core::Processor
      attr_accessor :year, :day

      validates :year, event_year: true
      validates :day, integer: { between: 1..25 }

      def validate
        super
        validate_event_set! if errors.empty?
      end

      def run
        return unless valid?

        create_or_update_puzzle!(fetch_content!, fetch_input!)
      end

      private

      def event
        @event ||= Event.first(year:)
      end

      def puzzle
        @puzzle ||= Puzzle.join(:events, id: :event_id).first(event:, day:)
      end

      def fetch_content!
        Core::Repository.get_puzzle(year:, day:)
      end

      def fetch_input!
        Core::Repository.get_input(year:, day:)
      end

      def create_or_update_puzzle!(content, input)
        if puzzle.nil?
          Puzzle.create(event:, day:, content:, input:)
        else
          puzzle.update(content:, input:)
        end
      end

      def validate_event_set!
        return unless event.nil?

        errors << Kangaru::Validation::Error.new(
          attribute: :event, message: "can't be blank"
        )
      end
    end
  end
end
