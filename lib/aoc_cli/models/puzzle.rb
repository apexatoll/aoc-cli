module AocCli
  class Puzzle < Kangaru::Model
    many_to_one :event

    validates :event, required: true
    validates :day, integer: { between: 1..25 }
    validates :content, required: true
    validates :input, required: true
  end
end
