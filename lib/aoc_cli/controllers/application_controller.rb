module AocCli
  class ApplicationController < Kangaru::Controller
    include Concerns::ErrorConcern
    include Concerns::LocationConcern

    def execute
      return handle_help_param! if params[:help]

      super
    rescue Core::Processor::Error => e
      render_model_errors!(e.processor)
    end

    private

    def handle_help_param!
      params.delete(:help)

      path = File.join("/help", request.path)
      request = Kangaru::Request.new(path:, params:)

      Kangaru.application!.router.resolve(request)
    end
  end
end
