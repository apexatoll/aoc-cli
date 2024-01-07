RSpec.shared_context :in_event_dir do |**options|
  let(:year)      { options[:year] || rand(2015..2023) }
  let(:event)     { create(:event, year:) }
  let!(:stats)    { create(:stats, event:) }
  let!(:location) { create(:location, :year_dir, event:, path: temp_dir) }
end
