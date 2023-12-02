module AocCli
  module Validators
    class EventYearValidator < Kangaru::Validator
      def validate
        case value
        when Integer  then validate_year!
        when NilClass then add_error!(ERRORS[:blank])
        else add_error!(ERRORS[:invalid])
        end
      end

      private

      ERRORS = {
        blank: "can't be blank",
        invalid: "is not an integer",
        too_low: "is before first Advent of Code event (2015)",
        too_high: "is in the future"
      }.freeze

      MIN_YEAR = 2015

      def max_year
        return Date.today.year if in_december?

        Date.today.year - 1
      end

      def in_december?
        Date.today.month == 12
      end

      def validate_year!
        if value < MIN_YEAR
          add_error!(ERRORS[:too_low])
        elsif value > max_year
          add_error!(ERRORS[:too_high])
        end
      end
    end
  end
end
