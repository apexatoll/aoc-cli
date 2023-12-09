module AocCli
  module Processors
    class StatsRefresher < Core::Processor
      attr_accessor :year

      validates :year, event_year: true

      def validate
        super
        validate_event_exists! if errors.empty?
      end

      private

      def event
        @event ||= Event.first(year:)
      end

      def validate_event_exists!
        return unless event.nil?

        errors << Kangaru::Validation::Error.new(
          attribute: :event, message: "can't be blank"
        )
      end
    end
  end
end
