RSpec.describe AocCli::Processors::PuzzleDirSynchroniser, :with_temp_dir do
  describe ".run!" do
    subject(:run_process) { described_class.run!(**attributes) }

    let(:attributes) { { puzzle:, location:, skip_cache: }.compact }

    let(:puzzle) { create(:puzzle, year:, day:) }

    let(:location) { create(:location, :puzzle_dir, puzzle:, path:) }

    let(:skip_cache) { nil }

    let(:year) { 2021 }

    let(:day) { 9 }

    context "when puzzle is nil" do
      let(:puzzle) { nil }
      let(:location) { create(:location, :puzzle_dir) }

      include_examples :failed_process, errors: ["Puzzle can't be blank"]
    end

    context "when location is nil" do
      let(:location) { nil }

      include_examples :failed_process, errors: ["Location can't be blank"]
    end

    context "when puzzle dir does not exist" do
      let(:path) { temp_path("does-not-exist").to_s }

      include_examples :failed_process, errors: ["Puzzle dir does not exist"]
    end

    context "when puzzle dir exists" do
      let(:path) { temp_dir }

      let(:puzzle_file) { puzzle_content_path(day: puzzle.day, dir: path) }

      let(:input_file) { puzzle_input_path(dir: path) }

      before do
        puzzle_file.write(current_puzzle) if current_puzzle
        input_file.write(current_input) if current_input
      end

      shared_examples :returns_puzzle_sync_log do |options|
        let(:puzzle_dir_sync_log) { AocCli::PuzzleDirSyncLog.last }

        it "creates a PuzzleDirSyncLog" do
          expect { run_process }.to create_model(AocCli::PuzzleDirSyncLog)
        end

        it "sets the expected PuzzleDirSyncLog attributes" do
          run_process

          expect(puzzle_dir_sync_log).to have_attributes(
            puzzle:, location:, **options
          )
        end

        it "returns the PuzzleDirSyncLong" do
          expect(run_process).to eq(puzzle_dir_sync_log)
        end
      end

      shared_examples :handles_puzzle_cache do
        before do
          stub_request(:get, puzzle_url(puzzle))
            .to_return(body: wrap_in_html(puzzle.content.reverse))

          stub_request(:get, input_url(puzzle))
            .to_return(body: puzzle.input.reverse)
        end

        context "when skip cache flag is false" do
          let(:skip_cache) { false }

          it "does not request the puzzle content" do
            expect { run_process }.not_to request(puzzle_url(puzzle))
          end

          it "does not request the puzzle input" do
            expect { run_process }.not_to request(input_url(puzzle))
          end
        end

        context "when skip cache flag is true" do
          let(:skip_cache) { true }

          it "requests the puzzle content" do
            expect { run_process }.to request(puzzle_url(puzzle))
          end

          it "requests the puzzle input" do
            expect { run_process }.to request(input_url(puzzle))
          end
        end
      end

      context "when puzzle file does not exist" do
        let(:current_puzzle) { nil }

        context "and input file does not exist" do
          let(:current_input) { nil }

          include_examples :handles_puzzle_cache

          it "creates the puzzle file" do
            expect { run_process }
              .to create_temp_file(puzzle_file)
              .with_contents(puzzle.content)
          end

          it "creates the input file" do
            expect { run_process }
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
            expect { run_process }
              .to create_temp_file(puzzle_file)
              .with_contents(puzzle.content)
          end

          it "does not update the input file" do
            expect { run_process }.not_to update_temp_file(input_file)
          end

          include_examples :returns_puzzle_sync_log,
                           puzzle_status: :new,
                           input_status: :unmodified
        end

        context "and fetched input differs from current file" do
          let(:current_input) { puzzle.input.reverse }

          include_examples :handles_puzzle_cache

          it "creates the puzzle file" do
            expect { run_process }
              .to create_temp_file(puzzle_file)
              .with_contents(puzzle.content)
          end

          it "updates the input file" do
            expect { run_process }
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
            expect { run_process }.not_to update_temp_file(puzzle_file)
          end

          it "creates the input file" do
            expect { run_process }
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
            expect { run_process }.not_to update_temp_file(puzzle_file)
          end

          it "does not update the input file" do
            expect { run_process }.not_to update_temp_file(input_file)
          end

          include_examples :returns_puzzle_sync_log,
                           puzzle_status: :unmodified,
                           input_status: :unmodified
        end

        context "and fetched input differs from current file" do
          let(:current_input) { puzzle.input.reverse }

          include_examples :handles_puzzle_cache

          it "skips the puzzle file" do
            expect { run_process }.not_to update_temp_file(puzzle_file)
          end

          it "updates the input file" do
            expect { run_process }
              .to update_temp_file(input_file)
              .to(puzzle.input)
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
            expect { run_process }
              .to update_temp_file(puzzle_file)
              .to(puzzle.content)
          end

          it "creates the input file" do
            expect { run_process }
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
            expect { run_process }
              .to update_temp_file(puzzle_file)
              .to(puzzle.content)
          end

          it "does not update the input file" do
            expect { run_process }
              .not_to update_temp_file(input_file)
          end

          include_examples :returns_puzzle_sync_log,
                           puzzle_status: :modified,
                           input_status: :unmodified
        end

        context "and fetched input differs from current file" do
          let(:current_input) { puzzle.input.reverse }

          include_examples :handles_puzzle_cache

          it "updates the puzzle file" do
            expect { run_process }
              .to update_temp_file(puzzle_file)
              .to(puzzle.content)
          end

          it "updates the input file" do
            expect { run_process }
              .to update_temp_file(input_file)
              .to(puzzle.input)
          end

          include_examples :returns_puzzle_sync_log,
                           puzzle_status: :modified,
                           input_status: :modified
        end
      end
    end
  end
end
