module AocCli
  class PuzzleController < ApplicationController
    def init
      return unless ensure_in_event_dir!

      @puzzle = Processors::PuzzleInitialiser.run!(
        event: current_event,
        day: target_id
      )
    end
  end
end
