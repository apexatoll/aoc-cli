module AocCli
  class ApplicationController < Kangaru::Controller
    include Helpers::ErrorHelper
    include Helpers::LocationHelper

    def execute
      super
    rescue Core::Processor::Error => e
      render_model_errors!(e.processor)
    end
  end
end
