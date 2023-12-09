module AocCli
  module Processors
    class StatsRefresher < Core::Processor
      attr_accessor :year

      validates :year, event_year: true

      # TODO: use conditional validations when supported by Kangaru
      def validate
        super
        validate_event_exists! if errors.empty?
      end

      def run
        return unless valid?

        create_or_update_stats!(fetch_stats!)
      end

      private

      def event
        @event ||= Event.first(year:)
      end

      def event!
        event || raise
      end

      def fetch_stats!
        Core::Repository.get_stats(year:)
      end

      def create_or_update_stats!(data)
        if event!.stats.nil?
          Stats.create(event:, **data)
        else
          event!.stats.update(**data)
        end
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
