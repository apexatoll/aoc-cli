module AocCli
  class Progress < Kangaru::Model
    many_to_one :puzzle

    validates :puzzle, required: true
    validates :level, integer: { between: 1..2 }
    validates :started_at, required: true

    def complete!
      update(completed_at: Time.now)
    end

    def reset!
      update(started_at: Time.now)
    end
  end
end
