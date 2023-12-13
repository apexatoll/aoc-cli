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

      def blank_stats
        1.upto(25).to_h { |i| [:"day_#{i}", 0] }
      end

      # Merge with a template hash that sets all days to 0 by default.
      # This is to prevent validation failing when fetching stats for an event
      # that is still in progress and not all the stats are populated.
      def fetch_stats!
        blank_stats.merge(Core::Repository.get_stats(year:))
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
