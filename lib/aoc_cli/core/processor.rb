module AocCli
  module Core
    class Processor
      extend Forwardable

      include Kangaru::Attributable
      include Kangaru::Validatable

      class Error < StandardError
        attr_reader :processor

        def initialize(processor)
          @processor = processor
        end
      end

      def run
        raise NotImplementedError
      end

      def run!
        raise(Error, self) unless valid?

        run
      end

      def self.run!(...)
        new(...).run!
      end
    end
  end
end
