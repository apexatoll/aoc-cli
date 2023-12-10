module AocCli
  class Location < Kangaru::Model
    many_to_one :resource, polymorphic: true

    validates :resource, required: true
    validates :path, required: true

    def exists?
      File.exist?(path)
    end
  end
end
