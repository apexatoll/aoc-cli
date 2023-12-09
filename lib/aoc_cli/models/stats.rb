module AocCli
  class Stats < Kangaru::Model
    many_to_one :event

    validates :event, required: true

    1.upto(25) do |i|
      validates :"day_#{i}", integer: { between: 0..2 }
    end

    def progress(day)
      self[:"day_#{day}"] || raise("invalid day")
    end

    def current_level(day)
      return if complete?(day)

      progress(day) + 1
    end

    def complete?(day)
      progress(day) == 2
    end

    def advance_progress!(day)
      raise "already complete" if complete?(day)

      update("day_#{day}": current_level(day))
    end
  end
end
