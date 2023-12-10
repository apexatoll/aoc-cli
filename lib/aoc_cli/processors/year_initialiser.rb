module AocCli
  module Processors
    class YearInitialiser < Core::Processor
      attr_accessor :year, :dir

      validates :year, event_year: true
      validates :dir, path: { exists: true }

      # TODO: replace with path validator when Kangaru supports conditional
      # validation.
      def validate
        super
        validate_year_dir_does_not_exist! if errors.empty?
      end

      private

      def year_dir
        @year_dir ||= File.join(dir, year.to_s)
      end

      def validate_year_dir_does_not_exist!
        return unless File.exist?(year_dir)

        errors << Kangaru::Validation::Error.new(
          attribute: :year_dir, message: "already exists"
        )
      end
    end
  end
end
