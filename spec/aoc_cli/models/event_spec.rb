RSpec.describe AocCli::Event do
  subject(:event) { described_class.new(**attributes) }

  let(:attributes) { { year: }.compact }

  describe "validations" do
    include_examples :validates_event_year
  end
end
