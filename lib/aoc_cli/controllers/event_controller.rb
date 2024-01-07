module AocCli
  class EventController < ApplicationController
    def init
      return unless ensure_not_in_aoc_dir!

      @event = Processors::EventInitialiser.run!(
        year: target_id,
        dir: params[:dir] || current_path
      )
    end
  end
end
