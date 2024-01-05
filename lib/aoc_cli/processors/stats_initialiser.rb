module AocCli
  module Processors
    class StatsInitialiser < Core::Processor
      attr_accessor :event

      validates :event, type: { equals: Event }

      def validate
        super
        validate_stats_do_not_exist! if errors.empty?
      end

      def run
        stats = BLANK_STATS.merge(fetch_stats!)

        Stats.create(event:, **stats)
      end

      private

      BLANK_STATS = 1.upto(25).to_h { |day| [:"day_#{day}", 0] }

      def fetch_stats!
        Core::Repository.get_stats(year: event.year)
      end

      def validate_stats_do_not_exist!
        return if event.stats.nil?

        errors << Kangaru::Validation::Error.new(
          attribute: :stats, message: "already exist"
        )
      end
    end
  end
end
