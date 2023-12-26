module AocCli
  module Processors
    class EventInitialiser < Core::Processor
      validates :year, event_year: true

      validates :dir, path: { exists: true }

      attr_accessor :year, :dir

      # TODO: use conditional validation once supported by Kangaru
      def validate
        super
        validate_event_not_already_initialised! if errors.empty?
        validate_event_dir_does_not_exist! if errors.empty?
      end

      def run
        create_event!.tap do |event|
          make_event_directory!
          attach_event!(event)
        end
      end

      private

      def event_dir
        @event_dir ||= Pathname(dir).join(year.to_s)
      end

      def create_event!
        Event.create(year:)
      end

      def make_event_directory!
        event_dir.mkdir
      end

      def attach_event!(event)
        ResourceAttacher.run!(resource: event, path: event_dir.to_s)
      end

      def validate_event_dir_does_not_exist!
        return unless event_dir.exist?

        errors << Kangaru::Validation::Error.new(
          attribute: :event_dir, message: "already exists"
        )
      end

      def validate_event_not_already_initialised!
        return if Event.where(year:).empty?

        errors << Kangaru::Validation::Error.new(
          attribute: :event, message: "already initialised"
        )
      end
    end
  end
end
