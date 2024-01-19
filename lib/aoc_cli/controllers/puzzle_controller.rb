module AocCli
  class PuzzleController < ApplicationController
    def init
      return unless ensure_in_event_dir!

      @puzzle = Processors::PuzzleInitialiser.run!(
        event: current_event,
        day: target_id
      )
    end

    def solve
      return unless ensure_in_puzzle_dir!

      @attempt = Processors::SolutionPoster.run!(
        puzzle: current_puzzle,
        answer: params[:answer]
      )
    end

    def sync
      return unless ensure_in_puzzle_dir!

      @sync_log = Processors::PuzzleDirSynchroniser.run!(
        puzzle: current_puzzle,
        location: current_location,
        skip_cache: params[:skip_cache] || false
      )

      Components::PuzzleSyncComponent.new(log: @sync_log).render
    end

    def attempts
      return unless ensure_in_puzzle_dir!

      Components::AttemptsTable.new(puzzle: current_puzzle || raise).render
    end
  end
end
