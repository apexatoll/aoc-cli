module AocCli
  module Validators
    class CollectionTypeValidator < Kangaru::Validator
      def validate
        validate_preconditions!

        return add_error!("can't be blank") if value.nil?
        return add_error!("is not an array") unless value.is_a?(Array)

        case validation_rule
        when :all  then validate_all_elements!
        when :any  then validate_any_elements!
        when :none then validate_none_elements!
        else raise
        end
      end

      private

      VALIDATION_RULES = %i[all any none].freeze

      ERROR = "elements have incompatible types".freeze

      def validation_rule
        @validation_rule ||= params.slice(*VALIDATION_RULES).keys.first || raise
      end

      def target_type
        @target_type ||= params[validation_rule]
      end

      def validate_preconditions!
        return if params.slice(*VALIDATION_RULES).count == 1

        raise "Collection type rule must be one of #{VALIDATION_RULES.inspect}"
      end

      def validate_all_elements!
        return if value.all? { |element| element.is_a?(target_type) }

        add_error!(ERROR)
      end

      def validate_any_elements!
        return if value.any? { |element| element.is_a?(target_type) }

        add_error!(ERROR)
      end

      def validate_none_elements!
        return if value.none? { |element| element.is_a?(target_type) }

        add_error!(ERROR)
      end
    end
  end
end
