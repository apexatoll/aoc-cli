RSpec.describe AocCli::Validators::EventYearValidator do
  subject(:model) { model_class.new(year:) }

  let(:model_class) do
    Class.new do
      include Kangaru::Validatable

      attr_reader :year

      def initialize(year:)
        @year = year
      end

      validates :year, event_year: true
    end
  end

  describe "#validate" do
    context "when year is nil" do
      let(:year) { nil }

      include_examples :invalid, errors: ["Year can't be blank"]
    end

    context "when year is not an integer" do
      let(:year) { :foobar }

      include_examples :invalid, errors: ["Year is not an integer"]
    end

    context "when year is an integer" do
      context "and year is before first AoC event" do
        let(:year) { 2014 }

        include_examples :invalid, errors: [
          "Year is before first Advent of Code event (2015)"
        ]
      end

      context "and year is in the future" do
        let(:year) { 3010 }

        include_examples :invalid, errors: ["Year is in the future"]
      end

      context "and year is valid" do
        let(:year) { 2023 }

        include_examples :valid
      end
    end
  end
end
