RSpec.describe AocCli::Processors::PuzzleRefresher do
  subject(:puzzle_refresher) { described_class.new(**attributes) }

  let(:attributes) { { year:, day: }.compact }

  describe "validations" do
    let(:year) { 2021 }

    let(:day) { 2 }

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

      context "and day is nil" do
        let(:day) { nil }

        include_examples :invalid, errors: ["Day can't be blank"]
      end

      context "and day is not an integer" do
        let(:day) { :foobar }

        include_examples :invalid, errors: ["Day is not an integer"]
      end

      context "and day is less than 1" do
        let(:day) { 0 }

        include_examples :invalid, errors: ["Day is too small"]
      end

      context "and day is more than 25" do
        let(:day) { 26 }

        include_examples :invalid, errors: ["Day is too large"]
      end

      context "and day is valid" do
        let(:day) { 8 }

        context "and event does not exist" do
          include_examples :invalid, errors: ["Event can't be blank"]
        end

        context "and event exists" do
          before { create(:event, year:) }

          include_examples :valid
        end
      end
    end
  end
end
