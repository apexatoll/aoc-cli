module AocCli
  class Puzzle < Kangaru::Model
    extend Forwardable

    many_to_one :event
    one_to_one :location, as: :resource
    one_to_many :attempts

    validates :event, required: true
    validates :day, integer: { between: 1..25 }
    validates :content, required: true
    validates :input, required: true

    def_delegators :event, :year

    def presenter
      @presenter ||= Presenters::PuzzlePresenter.new(self)
    end

    def mark_complete!(level)
      case level
      when 1 then update(part_one_completed_at: Time.now)
      when 2 then update(part_two_completed_at: Time.now)
      else raise "invalid level"
      end
    end
  end
end
