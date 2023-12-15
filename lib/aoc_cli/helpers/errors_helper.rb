module AocCli
  module Helpers
    module ErrorsHelper
      def render_errors!(*errors)
        Components::ErrorsComponent.new(*errors).render

        false
      end

      def render_model_errors!(model)
        Components::ErrorsComponent.from_model(model).render

        false
      end
    end
  end
end
