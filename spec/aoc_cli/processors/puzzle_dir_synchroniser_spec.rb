RSpec.describe AocCli::Processors::PuzzleDirSynchroniser, :with_temp_dir do
  subject(:puzzle_dir_synchroniser) { described_class.new(**attributes) }

  let(:year) { 2021 }

  let(:day) { 9 }

  let(:attributes) { { puzzle:, location:, skip_cache: }.compact }

  let(:puzzle) { create(:puzzle, year:, day:) }

  let(:location) { create(:location, :puzzle_dir, puzzle:, path:) }

  let(:skip_cache) { nil }

  describe "validations" do
    context "when puzzle is nil" do
      let(:puzzle) { nil }
      let(:location) { create(:location, :puzzle_dir) }

      include_examples :invalid, errors: ["Puzzle can't be blank"]
    end

    context "when location is nil" do
      let(:location) { nil }

      include_examples :invalid, errors: ["Location can't be blank"]
    end

    context "when puzzle dir does not exist" do
      let(:path) { temp_path("does-not-exist").to_s }

      include_examples :invalid, errors: ["Puzzle dir does not exist"]
    end

    context "when puzzle dir exists" do
      let(:path) { temp_dir }

      include_examples :valid
    end
  end

  describe "#run" do
    subject(:run) { puzzle_dir_synchroniser.run }

    let(:puzzle_file) { puzzle_content_path(day: puzzle.day, dir: path) }

    let(:input_file) { puzzle_input_path(dir: path) }

    shared_examples :returns_puzzle_sync_log do |options|
      let(:puzzle_dir_sync_log) { AocCli::PuzzleDirSyncLog.last }

      it "creates a PuzzleDirSyncLog" do
        expect { run }.to create_model(AocCli::PuzzleDirSyncLog)
      end

      it "sets the expected PuzzleDirSyncLog attributes" do
        run

        expect(puzzle_dir_sync_log).to have_attributes(
          puzzle:, location:, **options
        )
      end

      it "returns the PuzzleDirSyncLong" do
        expect(run).to eq(puzzle_dir_sync_log)
      end
    end

    shared_examples :handles_puzzle_cache do
      before do
        allow(AocCli::Processors::PuzzleRefresher).to receive(:run)
      end

      context "when skip cache flag is not specified" do
        let(:skip_cache) { nil }

        it "does not refresh the puzzle" do
          run

          expect(AocCli::Processors::PuzzleRefresher)
            .not_to have_received(:run)
        end
      end

      context "when skip cache flag is specfieid" do
        let(:skip_cache) { true }

        it "refreshes the puzzle" do
          run

          expect(AocCli::Processors::PuzzleRefresher)
            .to have_received(:run)
            .with(year:, day:, use_cache: false)
            .once
        end
      end
    end

    context "when invalid" do
      let(:path) { temp_path("does-not-exist").to_s }

      it "does not create the puzzle file" do
        expect { run }.not_to create_temp_file(puzzle_file)
      end

      it "does not create the input file" do
        expect { run }.not_to create_temp_file(input_file)
      end

      it "does not create a PuzzleDirSyncLog" do
        expect { run }.not_to create_model(AocCli::PuzzleDirSyncLog)
      end

      it "returns nil" do
        expect(run).to be_nil
      end
    end

    context "when valid" do
      let(:path) { temp_dir }

      before do
        puzzle_file.write(current_puzzle) if current_puzzle
        input_file.write(current_input) if current_input
      end

      context "when puzzle file does not exist" do
        let(:current_puzzle) { nil }

        context "and input file does not exist" do
          let(:current_input) { nil }

          include_examples :handles_puzzle_cache

          it "creates the puzzle file" do
            expect { run }
              .to create_temp_file(puzzle_file)
              .with_contents(puzzle.content)
          end

          it "creates the input file" do
            expect { run }
              .to create_temp_file(input_file)
              .with_contents(puzzle.input)
          end

          include_examples :returns_puzzle_sync_log,
                           puzzle_status: :new,
                           input_status: :new
        end

        context "and fetched input is same as current file" do
          let(:current_input) { puzzle.input }

          include_examples :handles_puzzle_cache

          it "creates the puzzle file" do
            expect { run }
              .to create_temp_file(puzzle_file)
              .with_contents(puzzle.content)
          end

          it "does not update the input file" do
            expect { run }.not_to update_temp_file(input_file)
          end

          include_examples :returns_puzzle_sync_log,
                           puzzle_status: :new,
                           input_status: :unmodified
        end

        context "and fetched input differs from current file" do
          let(:current_input) { puzzle.input.reverse }

          include_examples :handles_puzzle_cache

          it "creates the puzzle file" do
            expect { run }
              .to create_temp_file(puzzle_file)
              .with_contents(puzzle.content)
          end

          it "updates the input file" do
            expect { run }
              .to update_temp_file(input_file)
              .to(puzzle.input)
          end

          include_examples :returns_puzzle_sync_log,
                           puzzle_status: :new,
                           input_status: :modified
        end
      end

      context "when fetched puzzle is same as current file" do
        let(:current_puzzle) { puzzle.content }

        context "and input file does not exist" do
          let(:current_input) { nil }

          include_examples :handles_puzzle_cache

          it "skips the puzzle file" do
            expect { run }.not_to update_temp_file(puzzle_file)
          end

          it "creates the input file" do
            expect { run }
              .to create_temp_file(input_file)
              .with_contents(puzzle.input)
          end

          include_examples :returns_puzzle_sync_log,
                           puzzle_status: :unmodified,
                           input_status: :new
        end

        context "and fetched input is same as current file" do
          let(:current_input) { puzzle.input }

          include_examples :handles_puzzle_cache

          it "skips the puzzle file" do
            expect { run }.not_to update_temp_file(puzzle_file)
          end

          it "does not update the input file" do
            expect { run }.not_to update_temp_file(input_file)
          end

          include_examples :returns_puzzle_sync_log,
                           puzzle_status: :unmodified,
                           input_status: :unmodified
        end

        context "and fetched input differs from current file" do
          let(:current_input) { puzzle.input.reverse }

          include_examples :handles_puzzle_cache

          it "skips the puzzle file" do
            expect { run }.not_to update_temp_file(puzzle_file)
          end

          it "updates the input file" do
            expect { run }.to update_temp_file(input_file).to(puzzle.input)
          end

          include_examples :returns_puzzle_sync_log,
                           puzzle_status: :unmodified,
                           input_status: :modified
        end
      end

      context "when fetched puzzle differs from current file" do
        let(:current_puzzle) { puzzle.content.reverse }

        context "and input file does not exist" do
          let(:current_input) { nil }

          include_examples :handles_puzzle_cache

          it "updates the puzzle file" do
            expect { run }.to update_temp_file(puzzle_file).to(puzzle.content)
          end

          it "creates the input file" do
            expect { run }
              .to create_temp_file(input_file)
              .with_contents(puzzle.input)
          end

          include_examples :returns_puzzle_sync_log,
                           puzzle_status: :modified,
                           input_status: :new
        end

        context "and fetched input is same as current file" do
          let(:current_input) { puzzle.input }

          include_examples :handles_puzzle_cache

          it "updates the puzzle file" do
            expect { run }.to update_temp_file(puzzle_file).to(puzzle.content)
          end

          it "does not update the input file" do
            expect { run }.not_to update_temp_file(input_file)
          end

          include_examples :returns_puzzle_sync_log,
                           puzzle_status: :modified,
                           input_status: :unmodified
        end

        context "and fetched input differs from current file" do
          let(:current_input) { puzzle.input.reverse }

          include_examples :handles_puzzle_cache

          it "updates the puzzle file" do
            expect { run }.to update_temp_file(puzzle_file).to(puzzle.content)
          end

          it "updates the input file" do
            expect { run }.to update_temp_file(input_file).to(puzzle.input)
          end

          include_examples :returns_puzzle_sync_log,
                           puzzle_status: :modified,
                           input_status: :modified
        end
      end
    end
  end
end
