module AocCli
  class EventController < ApplicationController
    def init
      return unless ensure_not_in_aoc_dir!

      @event = Processors::EventInitialiser.run!(
        year: target_id,
        dir: params[:dir] || current_path
      )
    end

    def attach
      return render_error!("Event does not exist") if queried_event.nil?

      @source = queried_event.location.path

      @target = Processors::ResourceAttacher.run!(
        resource: queried_event,
        path: params[:dir] || current_path
      ).path
    end

    def progress
      return unless ensure_in_aoc_dir!

      Components::ProgressTable.new(event: current_event || raise).render
    end

    private

    def queried_event
      @queried_event ||= Event.first(year: target_id)
    end
  end
end
