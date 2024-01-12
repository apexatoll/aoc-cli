module AocCli
  module Concerns
    module LocationConcern
      def current_path
        File.expand_path(".")
      end

      def current_location
        Location.first(path: current_path)
      end

      def current_event
        case current_resource
        when Event then current_resource
        when Puzzle then current_resource.event
        end
      end

      def current_puzzle
        case current_resource
        when Puzzle then current_resource
        end
      end

      def ensure_in_event_dir!
        return true if in_event_dir?

        render_error!(ERRORS[:not_in_event])
      end

      def ensure_in_puzzle_dir!
        return true if in_puzzle_dir?

        render_error!(ERRORS[:not_in_puzzle])
      end

      def ensure_in_aoc_dir!
        return true if in_aoc_dir?

        render_error!(ERRORS[:not_in_aoc])
      end

      def ensure_not_in_aoc_dir!
        return true unless in_aoc_dir?

        render_error!(ERRORS[:in_aoc])
      end

      private

      ERRORS = {
        not_in_event:
          "Action can't be performed outside event directory",
        not_in_puzzle:
          "Action can't be performed outside puzzle directory",
        not_in_aoc:
          "Action can't be performed outside Advent of Code directory",
        in_aoc:
          "Action can't be performed from Advent of Code directory"
      }.freeze

      def current_resource
        current_location&.resource
      end

      def in_event_dir?
        current_location&.event_dir? || false
      end

      def in_puzzle_dir?
        current_location&.puzzle_dir? || false
      end

      def in_aoc_dir?
        in_event_dir? || in_puzzle_dir?
      end
    end
  end
end
