module AocCli
  module Core
    class Processor
      include Kangaru::Validatable
      include Kangaru::Attributable

      def run
        raise NotImplementedError
      end

      def self.run(...)
        new(...).run
      end
    end
  end
end
