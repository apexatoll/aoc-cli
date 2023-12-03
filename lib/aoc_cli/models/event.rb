module AocCli
  class Event < Kangaru::Model
    validates :year, event_year: true
  end
end
