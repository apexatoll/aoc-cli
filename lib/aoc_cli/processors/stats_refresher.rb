module AocCli
  module Processors
    class StatsRefresher < Core::Processor
      attr_accessor :stats

      validates :stats, type: { equals: Stats }

      def run
        stats.update(**updated_stats) || stats
      end

      private

      extend Forwardable

      def_delegators :stats, :year

      def updated_stats
        Core::Repository.get_stats(year:)
      end
    end
  end
end
