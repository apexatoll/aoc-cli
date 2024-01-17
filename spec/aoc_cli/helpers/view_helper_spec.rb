RSpec.describe AocCli::Helpers::ViewHelper do
  subject(:target) { Class.new { include AocCli::Helpers::ViewHelper }.new }

  describe "#main_header" do
    subject(:main_header) { target.main_header }

    it "returns the expected bold cyan header" do
      expect(main_header).to match(
        /\e\[1;36;49maoc-cli::<\d+\.\d+\.\d+>\e\[0m/
      )
    end
  end

  describe "#heading" do
    subject(:heading) { target.heading(text) }

    let(:text) { "Hello world" }

    it "returns the expected bold cyan string" do
      expect(heading).to eq("\e[1;36;49mHello world\e[0m")
    end
  end

  describe "#table_for" do
    subject(:table) { target.table_for(*rows, gap:, indent:) }

    let(:rows) { [%i[foo bar baz], %i[foo bar baz]] }

    let(:gap) { 2 }

    let(:indent) { 0 }

    let(:table_generator) do
      instance_double(AocCli::Helpers::TableGenerator, generate!: output)
    end

    let(:output) { "this is a table" }

    before do
      allow(AocCli::Helpers::TableGenerator)
        .to receive(:new)
        .and_return(table_generator)
    end

    it "instantiates a TableGenerator" do
      table

      expect(AocCli::Helpers::TableGenerator)
        .to have_received(:new)
        .with(rows:, gap:, indent:)
        .once
    end

    it "generates the table" do
      table
      expect(table_generator).to have_received(:generate!).once
    end

    it "returns the generated table" do
      expect(table).to eq(output)
    end
  end

  describe "#wrap_text" do
    subject(:wrapped_text) { target.wrap_text(text, width:, indent:) }

    let(:text) do
      <<~TEXT
        Features include downloading puzzles and inputs, solving puzzles and tracking year progress from within the terminal. This is an unofficial project with no affiliation to Advent of Code.
      TEXT
    end

    shared_examples :returns_wrapped_text do
      it "returns the expected wrapped string" do
        expect(wrapped_text).to eq(expected.gsub("|", ""))
      end
    end

    context "when indent is 0" do
      let(:indent) { 0 }

      context "and width is 1" do
        let(:width) { 1 }

        include_examples :returns_wrapped_text do
          let(:expected) do
            <<~TEXT
              |Features
              |include
              |downloading
              |puzzles
              |and
              |inputs,
              |solving
              |puzzles
              |and
              |tracking
              |year
              |progress
              |from
              |within
              |the
              |terminal.
              |This
              |is
              |an
              |unofficial
              |project
              |with
              |no
              |affiliation
              |to
              |Advent
              |of
              |Code.
            TEXT
          end
        end
      end

      context "and width is 20" do
        let(:width) { 20 }

        include_examples :returns_wrapped_text do
          let(:expected) do
            <<~TEXT
              |Features include
              |downloading puzzles
              |and inputs, solving
              |puzzles and tracking
              |year progress from
              |within the terminal.
              |This is an
              |unofficial project
              |with no affiliation
              |to Advent of Code.
            TEXT
          end
        end
      end

      context "and width is 40" do
        let(:width) { 40 }

        include_examples :returns_wrapped_text do
          let(:expected) do
            <<~TEXT
              |Features include downloading puzzles and
              |inputs, solving puzzles and tracking
              |year progress from within the terminal.
              |This is an unofficial project with no
              |affiliation to Advent of Code.
            TEXT
          end
        end
      end

      context "and width is 80" do
        let(:width) { 80 }

        include_examples :returns_wrapped_text do
          let(:expected) do
            <<~TEXT
              |Features include downloading puzzles and inputs, solving puzzles and tracking
              |year progress from within the terminal. This is an unofficial project with no
              |affiliation to Advent of Code.
            TEXT
          end
        end
      end
    end

    context "when indent is 2" do
      let(:indent) { 2 }

      context "and width is 1" do
        let(:width) { 1 }

        it "raises an error" do
          expect { wrapped_text }.to raise_error(
            "indent must be less than width"
          )
        end
      end

      context "and width is 20" do
        let(:width) { 20 }

        include_examples :returns_wrapped_text do
          let(:expected) do
            <<~TEXT
              |  Features include
              |  downloading
              |  puzzles and
              |  inputs, solving
              |  puzzles and
              |  tracking year
              |  progress from
              |  within the
              |  terminal. This is
              |  an unofficial
              |  project with no
              |  affiliation to
              |  Advent of Code.
            TEXT
          end
        end
      end

      context "and width is 40" do
        let(:width) { 40 }

        include_examples :returns_wrapped_text do
          let(:expected) do
            <<~TEXT
              |  Features include downloading puzzles
              |  and inputs, solving puzzles and
              |  tracking year progress from within the
              |  terminal. This is an unofficial
              |  project with no affiliation to Advent
              |  of Code.
            TEXT
          end
        end
      end

      context "and width is 80" do
        let(:width) { 80 }

        include_examples :returns_wrapped_text do
          let(:expected) do
            <<~TEXT
              |  Features include downloading puzzles and inputs, solving puzzles and tracking
              |  year progress from within the terminal. This is an unofficial project with no
              |  affiliation to Advent of Code.
            TEXT
          end
        end
      end
    end
  end
end
