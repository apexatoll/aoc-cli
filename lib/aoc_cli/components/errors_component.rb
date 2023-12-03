module AocCli
  module Components
    class ErrorsComponent < Kangaru::Component
      attr_reader :messages

      def initialize(*messages)
        @messages = messages
      end

      # TODO: remove once Kangaru has native conditional rendering
      def render
        return unless render?

        super
      end

      def self.from_model(model)
        errors = model.errors.map(&:full_message)

        new(*errors)
      end

      private

      def render?
        !messages.empty?
      end

      # TODO: move this to a const when Kangaru allows binding-agnostic
      # component constants (like controllers).
      def title
        "Error"
      end
    end
  end
end
