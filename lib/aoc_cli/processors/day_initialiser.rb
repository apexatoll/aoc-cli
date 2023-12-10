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
