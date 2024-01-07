RSpec.shared_context :in_puzzle_dir do |**options|
  let(:year)      { options[:year] || rand(2015..2023) }
  let(:day)       { options[:day] || rand(1..25) }
  let(:event)     { create(:event, year:) }
  let!(:stats)    { create(:stats, event:) }
  let(:puzzle)    { create(:puzzle, event:, day:) }
  let!(:location) { create(:location, :puzzle_dir, puzzle:, path: temp_dir) }

  let(:puzzle_file) { puzzle_content_path(dir: temp_dir, day:) }
  let(:input_file)  { puzzle_input_path(dir: temp_dir) }

  shared_context :puzzle_files_exist do
    before do
      puzzle_file.write(current_puzzle)
      input_file.write(current_input)
    end
  end
end
