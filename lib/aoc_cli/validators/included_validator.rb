module AocCli
  module Validators
    class IncludedValidator < Kangaru::Validator
      def validate
        return if allowed_values.include?(value)

        add_error!(ERRORS[:not_included])
      end

      private

      ERRORS = {
        not_included: "is not a valid option"
      }.freeze

      def allowed_values
        params[:in]
      end
    end
  end
end
