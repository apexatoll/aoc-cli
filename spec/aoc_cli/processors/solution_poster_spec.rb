RSpec.describe AocCli::Processors::SolutionPoster do
  subject(:solution_parser) { described_class.new(**attributes) }

  let(:attributes) { { year:, day:, answer: }.compact }

  describe "validations" do
    let(:year) { 2016 }
    let(:day) { 3 }
    let(:answer) { 100 }

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
      let(:year) { 2016 }

      context "and day is nil" do
        let(:day) { nil }

        include_examples :invalid, errors: ["Day can't be blank"]
      end

      context "and day is not an integer" do
        let(:day) { :foobar }

        include_examples :invalid, errors: ["Day is not an integer"]
      end

      context "and day is 0" do
        let(:day) { 0 }

        include_examples :invalid, errors: ["Day is too small"]
      end

      context "and day is after last event day" do
        let(:day) { 26 }

        include_examples :invalid, errors: ["Day is too large"]
      end

      context "and day is valid" do
        let(:day) { 3 }

        context "and answer is nil" do
          let(:answer) { nil }

          include_examples :invalid, errors: ["Answer can't be blank"]
        end

        context "and answer is present" do
          let(:answer) { 100 }

          context "and event for given year does not exist" do
            include_examples :invalid, errors: ["Event can't be blank"]
          end

          context "and event for given year exists" do
            let!(:event) { create(:event, year:) }

            context "and stats for given year do not exist" do
              include_examples :invalid, errors: ["Stats can't be blank"]
            end

            context "and stats for given year exist" do
              let!(:stats) { create(:stats, event:, day_3: progress) }

              let(:progress) { 0 }

              context "and puzzle for given day does not exist" do
                include_examples :invalid, errors: ["Puzzle can't be blank"]
              end

              context "and puzzle for given day exists" do
                let!(:puzzle) { create(:puzzle, event:, day:) }

                context "and the puzzle is complete" do
                  let(:progress) { 2 }

                  include_examples :invalid, errors: [
                    "Puzzle is already complete"
                  ]
                end

                context "and the puzzle is half complete" do
                  let(:progress) { 1 }

                  include_examples :valid
                end

                context "and the puzzle is not complete" do
                  let(:progress) { 0 }

                  include_examples :valid
                end
              end
            end
          end
        end
      end
    end
  end
end
