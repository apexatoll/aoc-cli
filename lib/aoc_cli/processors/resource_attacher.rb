module AocCli
  module Processors
    class ResourceAttacher < Core::Processor
      extend Forwardable

      attr_accessor :resource, :path

      validates :resource, type: { one_of: [Event, Puzzle] }
      validates :path, path: { exists: true }

      def run
        if location.nil?
          Location.create(resource:, path:)
        else
          location&.update(path:) || location
        end
      end

      def_delegators :resource, :location
    end
  end
end
