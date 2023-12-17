module AocCli
  module Presenters
    class AttemptPresenter
      attr_reader :attempt

      def initialize(attempt)
        @attempt = attempt
      end

      def hint
        case attempt.hint
        when :too_low  then "Too low"
        when :too_high then "Too high"
        else "-"
        end
      end
    end
  end
end
