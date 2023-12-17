module AocCli
  class Attempt < Kangaru::Model
    many_to_one :puzzle

    enum :status, incorrect: 0, correct: 1, rate_limited: 2, wrong_level: 3

    enum :hint, too_low: 0, too_high: 1

    validates :puzzle, required: true

    validates :level, integer: { between: 1..2 }

    validates :answer, required: true

    validates :status, included: {
      in: %i[incorrect correct rate_limited wrong_level]
    }

    def presenter
      @presenter ||= Presenters::AttemptPresenter.new(self)
    end

    # TODO: move to a conditional validation when supported by Kangaru
    def validate
      super
      validate_hint_not_set! unless incorrect?
      validate_hint! if incorrect?
      validate_wait_time_not_set! if correct? || wrong_level?
      validate_wait_time_integer! if incorrect? || rate_limited?
    end

    private

    def validate_hint_not_set!
      return if hint.nil?

      errors << Kangaru::Validation::Error.new(
        attribute: :hint, message: "is not expected"
      )
    end

    def validate_hint!
      return if hint.nil?
      return if %i[too_low too_high].include?(hint)

      errors << Kangaru::Validation::Error.new(
        attribute: :hint, message: "is not a valid option"
      )
    end

    def validate_wait_time_not_set!
      return if wait_time.nil?

      errors << Kangaru::Validation::Error.new(
        attribute: :wait_time, message: "is not expected"
      )
    end

    def validate_wait_time_integer!
      return if wait_time.is_a?(Integer)

      errors << Kangaru::Validation::Error.new(
        attribute: :wait_time, message: "is not an integer"
      )
    end
  end
end
