module AocCli
  module Presenters
    class AttemptPresenter
      attr_reader :attempt

      def initialize(attempt)
        @attempt = attempt
      end

      def status
        case attempt.status
        when :wrong_level  then "Wrong level"
        when :rate_limited then "Rate limited"
        when :incorrect    then "Incorrect"
        when :correct      then "Correct"
        else raise
        end
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
