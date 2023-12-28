module AocCli
  module Processors
    class PuzzleInitialiser < Core::Processor
      attr_accessor :event, :day

      validates :event, required: true
      validates :day, integer: { between: 1..25 }

      def validate
        super
        validate_event_location_set! if errors.empty?
        validate_event_dir_exists! if errors.empty?
        validate_puzzle_dir_does_not_exist! if errors.empty?
      end

      def run
        create_or_update_puzzle!(fetch_content!, fetch_input!).tap do |puzzle|
          attach_puzzle_dir!(puzzle).tap do |location|
            write_puzzle_files!(puzzle, location)
          end
        end
      end

      private

      def_delegators :event, :year

      def event_dir
        @event_dir ||= event.location.to_pathname
      end

      def puzzle_dir
        @puzzle_dir ||= event_dir.join(day.to_s)
      end

      def existing_puzzle
        @existing_puzzle ||= Puzzle.first(event:, day:)
      end

      def fetch_content!
        Core::Repository.get_puzzle(year:, day:)
      end

      def fetch_input!
        Core::Repository.get_input(year:, day:)
      end

      def create_or_update_puzzle!(content, input)
        if existing_puzzle.nil?
          Puzzle.create(event:, day:, content:, input:)
        else
          existing_puzzle.update(content:, input:) || existing_puzzle
        end
      end

      def attach_puzzle_dir!(puzzle)
        puzzle_dir.mkdir

        ResourceAttacher.run!(resource: puzzle, path: puzzle_dir.to_s)
      end

      def write_puzzle_files!(puzzle, location)
        PuzzleDirSynchroniser.run!(puzzle:, location:)
      end

      def validate_event_location_set!
        return unless event.location.nil?

        errors << Kangaru::Validation::Error.new(
          attribute: :event_location, message: "can't be blank"
        )
      end

      def validate_event_dir_exists!
        return if event_dir.exist?

        errors << Kangaru::Validation::Error.new(
          attribute: :event_dir, message: "does not exist"
        )
      end

      def validate_puzzle_dir_does_not_exist!
        return unless puzzle_dir.exist?

        errors << Kangaru::Validation::Error.new(
          attribute: :puzzle_dir, message: "already exists"
        )
      end
    end
  end
end
