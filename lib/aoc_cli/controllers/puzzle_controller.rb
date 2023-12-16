module AocCli
  class PuzzleController < ApplicationController
    def init
      return unless validate_in_event_dir!

      processor = Processors::DayInitialiser.new(
        year: current_year,
        day: target_id
      )

      @puzzle = processor.run

      return render_model_errors!(processor) if @puzzle.nil?

      true
    end

    private

    def validate_in_event_dir!
      return true if in_event_dir?

      render_errors!(
        "Cannot perform that action from outside an event directory"
      )
    end
  end
end
