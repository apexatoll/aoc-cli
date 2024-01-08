module AocCli
  class EventController < ApplicationController
    def init
      return unless ensure_not_in_aoc_dir!

      @event = Processors::EventInitialiser.run!(
        year: target_id,
        dir: params[:dir] || current_path
      )
    end

    def progress
      return unless ensure_in_aoc_dir!

      Components::ProgressTable.new(event: current_event || raise).render
    end
  end
end
