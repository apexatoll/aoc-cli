module AocCli
  module Processors
    class PuzzleDirSynchroniser < Core::Processor
      attr_accessor :puzzle, :location, :skip_cache

      set_default skip_cache: false

      validates :puzzle, required: true
      validates :location, required: true

      # TODO: replace with conditional validation
      def validate
        super
        validate_puzzle_dir_exists! if errors.empty?
      end

      private

      def puzzle_dir
        @puzzle_dir ||= location.to_pathname
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
