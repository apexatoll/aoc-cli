module AocCli
  class EventController < ApplicationController
    def init
      processor = Processors::YearInitialiser.new(
        year: target_id,
        dir: params[:dir] || current_path
      )

      @event = processor.run

      return render_model_errors!(processor) if @event.nil?

      true
    end
  end
end
