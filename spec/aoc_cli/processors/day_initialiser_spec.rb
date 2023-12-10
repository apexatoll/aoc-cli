RSpec.describe AocCli::Processors::DayInitialiser, :with_temp_dir do
  subject(:day_initialiser) { described_class.new(**attributes) }

  let(:attributes) { { year:, day: }.compact }

  let(:year) { 2021 }

  let(:day) { 11 }

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
      let(:year) { 2044 }

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

      context "and day is too low" do
        let(:day) { 0 }

        include_examples :invalid, errors: ["Day is too small"]
      end

      context "and day is too high" do
        let(:day) { 26 }

        include_examples :invalid, errors: ["Day is too large"]
      end

      context "and day is valid" do
        let(:day) { 21 }

        context "and event for specified year does not exist" do
          include_examples :invalid, errors: ["Event can't be blank"]
        end

        context "and event for specified year exists" do
          let!(:event) { create(:event, year:) }

          context "and event does not specify a location" do
            include_examples :invalid, errors: ["Event location can't be blank"]
          end

          context "and event specifies a location" do
            let!(:location) { create(:location, :year_dir, event:, path:) }

            context "and year dir does not exist" do
              let(:path) { temp_path("some-dir").to_s }

              include_examples :invalid, errors: ["Event dir does not exist"]
            end

            context "and year dir exists" do
              let(:path) { temp_dir.to_s }

              context "and puzzle dir already exists" do
                before { temp_path(day.to_s).mkdir }

                include_examples :invalid, errors: ["Puzzle dir already exists"]
              end

              context "and puzzle dir does not already exist" do
                include_examples :valid
              end
            end
          end
        end
      end
    end
  end
end
