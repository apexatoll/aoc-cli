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
  end
end
