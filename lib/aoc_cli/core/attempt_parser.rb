module AocCli
  module Core
    class AttemptParser
      attr_reader :response

      def initialize(response)
        @response = response
      end

      def to_h
        { status:, hint:, wait_time: }.compact
      end

      private

      module Prefixes
        CORRECT      = /^That's the right answer/
        INCORRECT    = /^That's not the right answer/
        RATE_LIMITED = /^You gave an answer too recently/
        WRONG_LEVEL  = /^You don't seem to be solving the right level/
      end

      module Hints
        TOO_LOW  = /your answer is too low/
        TOO_HIGH = /your answer is too high/
      end

      module WaitTimes
        ONE_MINUTE          = /one minute/
        INCORRECT_FORMAT    = /(\d+) minutes/
        RATE_LIMITED_FORMAT = /(?:(\d+)m)/
      end

      def status
        case response
        when Prefixes::CORRECT      then :correct
        when Prefixes::INCORRECT    then :incorrect
        when Prefixes::RATE_LIMITED then :rate_limited
        when Prefixes::WRONG_LEVEL  then :wrong_level
        else raise "unexpected response"
        end
      end

      def hint
        case response
        when Hints::TOO_LOW  then :too_low
        when Hints::TOO_HIGH then :too_high
        end
      end

      def wait_time
        case status
        when :incorrect    then scan_incorrect_wait_time!
        when :rate_limited then scan_rated_limited_wait_time!
        end
      end

      def scan_incorrect_wait_time!
        return 1 if response.match?(WaitTimes::ONE_MINUTE)

        response.scan(WaitTimes::INCORRECT_FORMAT).flatten.first.to_i
      end

      def scan_rated_limited_wait_time!
        response.scan(WaitTimes::RATE_LIMITED_FORMAT).flatten.first.to_i
      end
    end
  end
end
