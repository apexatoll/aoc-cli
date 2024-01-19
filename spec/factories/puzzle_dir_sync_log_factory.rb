FactoryBot.define do
  factory :puzzle_dir_sync_log, class: "AocCli::PuzzleDirSyncLog" do
    puzzle        { association :puzzle, :with_location }
    location      { puzzle.location }
    puzzle_status { :unmodified }
    input_status  { :unmodified }
  end
end
