module AocCli
  module Helpers
    module ErrorsHelper
      def render_model_errors!(model)
        Components::ErrorsComponent.from_model(model).render

        false
      end
    end
  end
end
