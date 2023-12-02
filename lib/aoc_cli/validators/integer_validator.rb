module AocCli
  module Validators
    class IntegerValidator < Kangaru::Validator
      def validate
        return add_error!(ERRORS[:blank]) if value.nil?
        return add_error!(ERRORS[:type]) unless value.is_a?(Integer)

        validate_range! if params.keys.include?(:between)
      end

      private

      ERRORS = {
        blank: "can't be blank",
        type: "is not an integer",
        too_small: "is too small",
        too_large: "is too large"
      }.freeze

      def range
        params[:between]
      end

      def validate_range!
        return if range.include?(value)

        add_error!(ERRORS[:too_small]) if value < range.first
        add_error!(ERRORS[:too_large]) if value > params[:between].last
      end
    end
  end
end
