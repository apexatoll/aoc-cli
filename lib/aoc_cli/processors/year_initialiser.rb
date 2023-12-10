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

      def run
        return unless valid?

        find_or_create_event!.tap do |event|
          fetch_stats!
          create_or_update_location!(event)
          make_year_directory!
        end
      end

      private

      def year_dir
        @year_dir ||= File.join(dir, year.to_s)
      end

      def find_or_create_event!
        Event.find_or_create(year:)
      end

      def fetch_stats!
        StatsRefresher.run(year:)
      end

      def create_or_update_location!(event)
        if event.location.nil?
          Location.create(path: year_dir, resource: event)
        else
          event.location.update(path: year_dir, resource: event)
        end
      end

      def make_year_directory!
        Dir.mkdir(year_dir)
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
