module AocCli
  module Presenters
    class StatsPresenter
      attr_reader :stats

      def initialize(stats)
        @stats = stats
      end

      def total_progress
        total = 1.upto(25).map { |day| stats.progress(day) }.sum

        "#{total}/50"
      end

      def progress_icons(day)
        case stats.progress(day)
        when 0 then Icons::INCOMPLETE
        when 1 then Icons::HALF_COMPLETE
        when 2 then Icons::COMPLETE
        else raise
        end
      end

      module Icons
        INCOMPLETE    = "○ ○".freeze
        HALF_COMPLETE = "● ○".freeze
        COMPLETE      = "● ●".freeze
      end
    end
  end
end
