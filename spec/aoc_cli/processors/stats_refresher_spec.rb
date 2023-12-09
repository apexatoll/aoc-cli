RSpec.describe AocCli::Processors::StatsRefresher do
  subject(:stats_refresher) { described_class.new(year:) }

  describe "validations" do
    context "when year is nil" do
      let(:year) { nil }

      include_examples :invalid, errors: ["Year can't be blank"]
    end

    context "when year is not an integer" do
      let(:year) { :foobar }

      include_examples :invalid, errors: ["Year is not an integer"]
    end

    context "when year is before first AoC event" do
      let(:year) { 2014 }

      include_examples :invalid, errors: [
        "Year is before first Advent of Code event (2015)"
      ]
    end

    context "when year is after most recent AoC event" do
      let(:year) { 2028 }

      include_examples :invalid, errors: ["Year is in the future"]
    end

    context "when year is valid" do
      let(:year) { 2021 }

      context "and event does not exist" do
        before { create(:event, year: 2020) }

        include_examples :invalid, errors: ["Event can't be blank"]
      end

      context "and event exists" do
        before { create(:event, year:) }

        include_examples :valid
      end
    end
  end
end
