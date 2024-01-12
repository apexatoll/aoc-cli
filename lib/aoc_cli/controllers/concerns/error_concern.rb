module AocCli
  module Concerns
    module ErrorConcern
      def render_error!(error)
        Components::ErrorsComponent.new(error).render

        false
      end

      def render_model_errors!(model)
        Components::ErrorsComponent.from_model(model).render

        false
      end
    end
  end
end
