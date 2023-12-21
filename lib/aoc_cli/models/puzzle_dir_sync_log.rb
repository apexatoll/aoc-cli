module AocCli
  class PuzzleDirSyncLog < Kangaru::Model
    many_to_one :location
    many_to_one :puzzle

    validates :location, required: true
    validates :puzzle, required: true

    STATUS_ENUM = { new: 0, unmodified: 1, modified: 2 }.freeze

    enum :puzzle_status, STATUS_ENUM, prefix: true
    enum :input_status, STATUS_ENUM, prefix: true
  end
end
