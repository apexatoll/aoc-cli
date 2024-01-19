RSpec.describe AocCli::Components::PuzzleSyncComponent, :with_temp_dir do
  subject(:puzzle_sync_component) { described_class.new(log:) }

  let(:log) do
    create(
      :puzzle_dir_sync_log,
      puzzle:, location:,
      puzzle_status:, input_status:
    )
  end

  let(:puzzle) { create(:puzzle, day: 14) }

  let(:location) { create(:location, resource: puzzle, path: temp_dir) }

  describe "#render" do
    subject(:render) { puzzle_sync_component.render }

    shared_examples :renders_component do
      it "renders the component" do
        expect { render }.to output(expected).to_stdout
      end
    end

    context "when puzzle file unmodified" do
      let(:puzzle_status) { :unmodified }

      context "and input file unmodified" do
        let(:input_status) { :unmodified }

        include_examples :renders_component do
          let(:expected) do
            <<~TEXT
              Puzzle #{puzzle.presenter.date} dir synchronised
                day_14.md  unmodified
                input      unmodified
            TEXT
          end
        end
      end

      context "and input file modified" do
        let(:input_status) { :modified }

        include_examples :renders_component do
          let(:expected) do
            <<~TEXT
              Puzzle #{puzzle.presenter.date} dir synchronised
                day_14.md  unmodified
                input      modified
            TEXT
          end
        end
      end

      context "and input file new" do
        let(:input_status) { :new }

        include_examples :renders_component do
          let(:expected) do
            <<~TEXT
              Puzzle #{puzzle.presenter.date} dir synchronised
                day_14.md  unmodified
                input      new
            TEXT
          end
        end
      end
    end

    context "when puzzle file modified" do
      let(:puzzle_status) { :modified }

      context "and input file unmodified" do
        let(:input_status) { :unmodified }

        include_examples :renders_component do
          let(:expected) do
            <<~TEXT
              Puzzle #{puzzle.presenter.date} dir synchronised
                day_14.md  modified
                input      unmodified
            TEXT
          end
        end
      end

      context "and input file modified" do
        let(:input_status) { :modified }

        include_examples :renders_component do
          let(:expected) do
            <<~TEXT
              Puzzle #{puzzle.presenter.date} dir synchronised
                day_14.md  modified
                input      modified
            TEXT
          end
        end
      end

      context "and input file new" do
        let(:input_status) { :new }

        include_examples :renders_component do
          let(:expected) do
            <<~TEXT
              Puzzle #{puzzle.presenter.date} dir synchronised
                day_14.md  modified
                input      new
            TEXT
          end
        end
      end
    end

    context "when puzzle file new" do
      let(:puzzle_status) { :new }

      context "and input file unmodified" do
        let(:input_status) { :unmodified }

        include_examples :renders_component do
          let(:expected) do
            <<~TEXT
              Puzzle #{puzzle.presenter.date} dir synchronised
                day_14.md  new
                input      unmodified
            TEXT
          end
        end
      end

      context "and input file modified" do
        let(:input_status) { :modified }

        include_examples :renders_component do
          let(:expected) do
            <<~TEXT
              Puzzle #{puzzle.presenter.date} dir synchronised
                day_14.md  new
                input      modified
            TEXT
          end
        end
      end

      context "and input file new" do
        let(:input_status) { :new }

        include_examples :renders_component do
          let(:expected) do
            <<~TEXT
              Puzzle #{puzzle.presenter.date} dir synchronised
                day_14.md  new
                input      new
            TEXT
          end
        end
      end
    end
  end
end
