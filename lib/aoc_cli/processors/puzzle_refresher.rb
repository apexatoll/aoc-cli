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

      private

      def event
        @event ||= Event.first(year:)
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
