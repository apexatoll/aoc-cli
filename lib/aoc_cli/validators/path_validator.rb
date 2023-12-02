module AocCli
  module Validators
    class PathValidator < Kangaru::Validator
      def validate
        return add_error!(ERRORS[:blank]) if value.nil?

        if params[:exists] == false
          validate_path_does_not_exist!
        else
          validate_path_exists!
        end
      end

      private

      ERRORS = {
        blank: "can't be blank",
        exists: "already exists",
        does_not_exist: "does not exist"
      }.freeze

      def path_exists?
        File.exist?(value)
      end

      def validate_path_does_not_exist!
        return unless path_exists?

        add_error!(ERRORS[:exists])
      end

      def validate_path_exists!
        return if path_exists?

        add_error!(ERRORS[:does_not_exist])
      end
    end
  end
end
