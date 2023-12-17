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

    def progress
      if current_resource.nil?
        return render_errors!(
          "Cannot perform that action from outside an AoC directory"
        )
      end

      event = current_resource if in_event_dir?
      event = current_resource.event if in_puzzle_dir?

      Components::ProgressTable.new(event:).render
    end
  end
end
