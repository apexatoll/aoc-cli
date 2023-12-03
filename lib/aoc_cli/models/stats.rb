module AocCli
  class Stats < Kangaru::Model
    many_to_one :event

    validates :event, required: true

    1.upto(25) do |i|
      validates :"day_#{i}", integer: { between: 0..2 }
    end
  end
end
