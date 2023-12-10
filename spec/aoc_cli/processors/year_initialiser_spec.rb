RSpec.describe AocCli::Processors::YearInitialiser, :with_temp_dir do
  subject(:year_initialiser) { described_class.new(**attributes) }

  let(:attributes) { { year:, dir: } }

  describe "validations" do
    let(:dir) { temp_dir.to_s }

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
      let(:year) { 2040 }

      include_examples :invalid, errors: ["Year is in the future"]
    end

    context "when year is valid" do
      let(:year) { 2020 }

      context "and dir is nil" do
        let(:dir) { nil }

        include_examples :invalid, errors: ["Dir can't be blank"]
      end

      context "and dir does not exist" do
        let(:dir) { temp_path("does-not-exist").to_s }

        include_examples :invalid, errors: ["Dir does not exist"]
      end

      context "and dir exists" do
        let(:dir) { temp_dir.to_s }

        context "and year path already exists" do
          before { temp_path(year.to_s).mkdir }

          include_examples :invalid, errors: ["Year dir already exists"]
        end

        context "and year path does not already exist" do
          include_examples :valid
        end
      end
    end
  end
end
