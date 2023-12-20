module AocCli
  class Location < Kangaru::Model
    many_to_one :resource, polymorphic: true

    validates :resource, required: true
    validates :path, required: true

    def exists?
      File.exist?(path)
    end

    def event_dir?
      resource.is_a?(Event)
    end

    def puzzle_dir?
      resource.is_a?(Puzzle)
    end

    def to_pathname
      Pathname.new(path)
    end
  end
end
