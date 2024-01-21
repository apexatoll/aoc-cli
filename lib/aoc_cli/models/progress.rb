module AocCli
  class Progress < Kangaru::Model
    many_to_one :puzzle

    validates :puzzle, required: true
    validates :level, integer: { between: 1..2 }
    validates :started_at, required: true
  end
end
