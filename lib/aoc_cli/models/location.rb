module AocCli
  class Location < Kangaru::Model
    many_to_one :resource, polymorphic: true

    validates :resource, required: true
    validates :path, required: true
  end
end
