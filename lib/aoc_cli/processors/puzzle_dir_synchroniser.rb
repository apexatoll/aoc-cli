module AocCli
  module Processors
    class PuzzleDirSynchroniser < Core::Processor
      extend Forwardable

      attr_accessor :puzzle, :location, :skip_cache

      set_default skip_cache: false

      validates :puzzle, required: true
      validates :location, required: true

      # TODO: replace with conditional validation
      def validate
        super
        validate_puzzle_dir_exists! if errors.empty?
      end

      def run
        return unless valid?

        refresh_puzzle! if skip_cache

        create_puzzle_dir_sync_log!.tap do
          puzzle_file.write(puzzle.content)
          input_file.write(puzzle.input)
        end
      end

      private

      def_delegators :puzzle, :year, :day

      def puzzle_dir
        @puzzle_dir ||= location.to_pathname
      end

      def puzzle_file
        @puzzle_file ||= puzzle_dir.join(puzzle.presenter.puzzle_filename)
      end

      def input_file
        @input_file ||= puzzle_dir.join(puzzle.presenter.input_filename)
      end

      def refresh_puzzle!
        PuzzleRefresher.run(year:, day:, use_cache: false)

        puzzle.reload
      end

      def create_puzzle_dir_sync_log!
        PuzzleDirSyncLog.create(
          puzzle:, location:, puzzle_status:, input_status:
        )
      end

      def puzzle_status
        return :new unless puzzle_file.exist?

        puzzle_file.read == puzzle.content ? :unmodified : :modified
      end

      def input_status
        return :new unless input_file.exist?

        input_file.read == puzzle.input ? :unmodified : :modified
      end

      def validate_puzzle_dir_exists!
        return if puzzle_dir.exist?

        errors << Kangaru::Validation::Error.new(
          attribute: :puzzle_dir, message: "does not exist"
        )
      end
    end
  end
end
