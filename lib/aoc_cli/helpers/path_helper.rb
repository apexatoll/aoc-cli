module AocCli
  module Helpers
    module PathHelper
      def current_path
        @current_path ||= File.expand_path(".")
      end

      def current_location
        @current_location ||= Location.first(path: current_path)
      end

      def current_resource
        current_location&.resource
      end

      def current_year
        case current_resource
        when Event  then current_resource&.year
        when Puzzle then current_resource&.event&.year
        end
      end

      def current_day
        case current_resource
        when Puzzle then current_resource&.day
        end
      end

      def in_event_dir?
        current_location&.event_dir? || false
      end

      def in_puzzle_dir?
        current_location&.puzzle_dir? || false
      end
    end
  end
end
