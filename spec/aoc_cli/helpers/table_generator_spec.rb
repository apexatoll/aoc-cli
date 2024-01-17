RSpec.describe AocCli::Helpers::TableGenerator do
  subject(:table_generator) { described_class.new(rows:, gap:, indent:) }

  let(:gap) { 2 }

  let(:indent) { 0 }

  describe "#generate!" do
    subject(:table) { table_generator.generate! }

    shared_examples :raises_error do |message|
      it "raises an error" do
        expect { table }.to raise_error(message)
      end
    end

    shared_examples :generates_table do
      it "returns a String" do
        expect(table).to be_a(String)
      end

      it "returns the expected table" do
        expect(table).to eq_table(expected)
      end

      matcher :eq_table do |expected|
        match do |actual|
          formatted_table = expected.gsub("|", "").chomp

          expect(actual).to eq(formatted_table)
        end
      end
    end

    context "when rows is nil" do
      let(:rows) { nil }

      include_examples :raises_error, "Rows can't be blank"
    end

    context "when rows is not an array" do
      let(:rows) { "hello world" }

      include_examples :raises_error, "Rows is not an array"
    end

    context "when rows is an array" do
      context "and no row elements are arrays" do
        let(:rows) { %i[foo bar] }

        include_examples :raises_error, "Rows elements have incompatible types"
      end

      context "and some row elements are arrays" do
        let(:rows) { [%i[foo bar], :baz] }

        include_examples :raises_error, "Rows elements have incompatible types"
      end

      context "and all row elements are arrays" do
        context "and rows are not all the same length" do
          let(:rows) do
            [
              %w[Foo Bar],
              %w[Foo Bar Baz]
            ]
          end

          include_examples :raises_error, "Rows must all be the same length"
        end

        context "and rows are all the same length" do
          let(:rows) do
            [
              %w[Harry Potter Gryffindor],
              %w[Draco Malfoy Slytherin],
              %w[Hannah Abbott Hufflepuff],
              %w[Luna Lovegood Ravenclaw]
            ]
          end

          context "and indent is 0" do
            let(:indent) { 0 }

            context "and gap is 0" do
              let(:gap) { 0 }

              include_examples :generates_table do
                let(:expected) do
                  <<~TEXT
                    |Harry Potter  Gryffindor|
                    |Draco Malfoy  Slytherin |
                    |HannahAbbott  Hufflepuff|
                    |Luna  LovegoodRavenclaw |
                  TEXT
                end
              end
            end

            context "and gap is positive" do
              let(:gap) { 2 }

              include_examples :generates_table do
                let(:expected) do
                  <<~TEXT
                    |Harry   Potter    Gryffindor  |
                    |Draco   Malfoy    Slytherin   |
                    |Hannah  Abbott    Hufflepuff  |
                    |Luna    Lovegood  Ravenclaw   |
                  TEXT
                end
              end
            end
          end

          context "and indent is positive" do
            let(:indent) { 2 }

            context "and gap is 0" do
              let(:gap) { 0 }

              include_examples :generates_table do
                let(:expected) do
                  <<~TEXT
                    |  Harry Potter  Gryffindor|
                    |  Draco Malfoy  Slytherin |
                    |  HannahAbbott  Hufflepuff|
                    |  Luna  LovegoodRavenclaw |
                  TEXT
                end
              end
            end

            context "and gap is positive" do
              let(:gap) { 4 }

              include_examples :generates_table do
                let(:expected) do
                  <<~TEXT
                    |  Harry     Potter      Gryffindor    |
                    |  Draco     Malfoy      Slytherin     |
                    |  Hannah    Abbott      Hufflepuff    |
                    |  Luna      Lovegood    Ravenclaw     |
                  TEXT
                end
              end
            end
          end
        end
      end
    end
  end
end
