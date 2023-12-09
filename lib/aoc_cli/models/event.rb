module AocCli
  class Event < Kangaru::Model
    one_to_many :puzzles
    one_to_one  :stats
    one_to_one  :location, as: :resource

    validates :year, event_year: true
  end
end
