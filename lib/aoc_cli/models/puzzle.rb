module AocCli
  class Puzzle < Kangaru::Model
    extend Forwardable

    many_to_one :event
    one_to_one :location, as: :resource
    one_to_many :attempts

    one_to_one :part_one_progress,
               class: "AocCli::Progress",
               conditions: { level: 1 }

    one_to_one :part_two_progress,
               class: "AocCli::Progress",
               conditions: { level: 2 }

    validates :event, required: true
    validates :day, integer: { between: 1..25 }
    validates :content, required: true
    validates :input, required: true

    def_delegators :event, :year

    def presenter
      @presenter ||= Presenters::PuzzlePresenter.new(self)
    end
  end
end
