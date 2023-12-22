module AocCli
  module Validators
    class TypeValidator < Kangaru::Validator
      def validate
        validate_target_type_set!

        if params[:equals]
          validate_type!
        elsif params[:one_of]
          validate_type_from_list!
        end
      end

      private

      ERRORS = {
        blank: "can't be blank",
        type: "has incompatible type"
      }.freeze

      def valid_type
        params[:equals]
      end

      def valid_types
        params[:one_of]
      end

      def error
        return ERRORS[:blank] if value.nil?

        ERRORS[:type]
      end

      def validate_target_type_set!
        return if valid_type || valid_types

        raise "type must be specified via :equals or :one_of options"
      end

      def validate_type!
        return if value.is_a?(valid_type)

        add_error!(error)
      end

      def validate_type_from_list!
        return if valid_types&.include?(value.class)

        add_error!(error)
      end
    end
  end
end
