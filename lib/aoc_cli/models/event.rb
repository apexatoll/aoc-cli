module AocCli
  class Event < Kangaru::Model
    one_to_many :puzzles

    validates :year, event_year: true
  end
end
