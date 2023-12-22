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

    def solve
      return unless validate_in_puzzle_dir!

      processor = Processors::SolutionPoster.new(
        year: current_year,
        day: current_day,
        answer: params[:answer]
      )

      @attempt = processor.run

      return render_model_errors!(processor) if @attempt.nil?

      true
    end

    def sync
      return unless validate_in_puzzle_dir!

      processor = Processors::PuzzleDirSynchroniser.new(
        puzzle: current_resource,
        location: current_location,
        skip_cache: params[:skip_cache] || false
      )

      @log = processor.run

      return render_model_errors!(processor) if @log.nil?

      true
    end

    def attempts
      return unless validate_in_puzzle_dir!

      Components::AttemptsTable.new(puzzle: current_resource).render
    end

    private

    def validate_in_event_dir!
      return true if in_event_dir?

      render_errors!(
        "Cannot perform that action from outside an event directory"
      )
    end

    def validate_in_puzzle_dir!
      return true if in_puzzle_dir?

      render_errors!(
        "Cannot perform that action from outside a puzzle directory"
      )
    end
  end
end
