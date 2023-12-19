module AocCli
  module Processors
    class DayInitialiser < Core::Processor
      attr_accessor :year, :day

      validates :year, event_year: true
      validates :day, integer: { between: 1..25 }

      def validate
        super
        validate_event_is_initialised!      if errors.empty?
        validate_event_location_is_set!     if errors.empty?
        validate_event_dir_exists!          if errors.empty?
        validate_puzzle_dir_does_not_exist! if errors.empty?
      end

      def run
        return unless valid?

        refresh_puzzle!.tap do |puzzle|
          create_or_update_location!(puzzle)
          make_directory!
          write_files!(puzzle)
        end
      end

      private

      def event
        @event ||= Event.first(year:)
      end

      def event_dir
        raise if event.nil? || event.location.nil?

        @event_dir ||= event.location.path
      end

      def puzzle_dir
        raise if event.nil? || event.location.nil?

        @puzzle_dir ||= File.join(event.location.path, day.to_s)
      end

      def puzzle_path
        puzzle_file = "day_#{day.to_s.rjust(2, '0')}.md"

        File.join(puzzle_dir, puzzle_file)
      end

      def input_path
        File.join(puzzle_dir, "input")
      end

      def refresh_puzzle!
        PuzzleRefresher.run(year:, day:, use_cache: false)
      end

      def create_or_update_location!(puzzle)
        if puzzle.location.nil?
          Location.create(resource: puzzle, path: puzzle_dir)
        else
          puzzle.location.update(path: puzzle_dir)
        end
      end

      def make_directory!
        Dir.mkdir(puzzle_dir)
      end

      def write_files!(puzzle)
        File.write(puzzle_path, puzzle.content)
        File.write(input_path, puzzle.input)
      end

      def validate_event_is_initialised!
        return unless event.nil?

        errors << Kangaru::Validation::Error.new(
          attribute: :event, message: "can't be blank"
        )
      end

      def validate_event_location_is_set!
        return unless event&.location.nil?

        errors << Kangaru::Validation::Error.new(
          attribute: :event_location, message: "can't be blank"
        )
      end

      def validate_event_dir_exists!
        return if event&.location&.exists?

        errors << Kangaru::Validation::Error.new(
          attribute: :event_dir, message: "does not exist"
        )
      end

      def validate_puzzle_dir_does_not_exist!
        return unless File.exist?(puzzle_dir)

        errors << Kangaru::Validation::Error.new(
          attribute: :puzzle_dir, message: "already exists"
        )
      end
    end
  end
end
