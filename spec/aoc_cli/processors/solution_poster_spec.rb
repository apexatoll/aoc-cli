RSpec.describe AocCli::Processors::SolutionPoster do
  before { allow(Time).to receive(:now).and_return(now) }

  let(:now) { Time.now.round(6) }

  describe ".run!" do
    subject(:run_process) { described_class.run!(puzzle:, answer:) }

    shared_examples :handles_rate_limited_attempt do |options|
      let(:expected_attempt_attributes) do
        {
          puzzle:,
          answer:,
          level: progress + 1,
          status: :rate_limited,
          wait_time: options[:wait]
        }
      end

      it "posts the solution" do
        run_process
        assert_requested(:post, solution_url(puzzle))
      end

      it "creates an Attempt" do
        expect { run_process }
          .to create_model(AocCli::Attempt)
          .with_attributes(**expected_attempt_attributes)
      end

      it "does not change the puzzle attributes" do
        expect { run_process }.not_to change { puzzle.reload.values }
      end

      it "does not change the stats attributes" do
        expect { run_process }.not_to change { stats.reload.values }
      end

      it "returns the Attempt" do
        expect(run_process).to eq(attempt)
      end
    end

    shared_examples :handles_incorrect_attempt do |options|
      let(:expected_attempt_attributes) do
        {
          puzzle:,
          answer:,
          level: progress + 1,
          status: :incorrect,
          wait_time: options[:wait]
        }
      end

      it "posts the solution" do
        run_process
        assert_requested(:post, solution_url(puzzle))
      end

      it "creates an Attempt" do
        expect { run_process }
          .to create_model(AocCli::Attempt)
            .with_attributes(**expected_attempt_attributes)
      end

      it "does not change the puzzle attributes" do
        expect { run_process }.not_to change { puzzle.reload.values }
      end

      it "does not change the stats attributes" do
        expect { run_process }.not_to change { stats.reload.values }
      end

      it "returns the Attempt" do
        expect(run_process).to eq(attempt)
      end
    end

    shared_examples :handles_correct_attempt do |options|
      it "posts the solution" do
        run_process
        assert_requested(:post, solution_url(puzzle))
      end

      it "creates an Attempt" do
        expect { run_process }
          .to create_model(AocCli::Attempt)
          .with_attributes(puzzle:, status: :correct)
      end

      it "returns the attempt" do
        expect(run_process).to eq(attempt)
      end

      if options[:initial].zero?
        it "sets the part_one_completed_at timestamp" do
          expect { run_process }
            .to change { puzzle.reload.part_one_completed_at }
            .to(now)
        end

        it "does not set the part_two_completed_at timestamp" do
          expect { run_process }
            .not_to change { puzzle.reload.part_two_completed_at }
        end
      else
        it "does not set the part_one_completed_at timestamp" do
          expect { run_process }
            .not_to change { puzzle.reload.part_one_completed_at }
        end

        it "sets the part_two_completed_at timestamp" do
          expect { run_process }
            .to change { puzzle.reload.part_two_completed_at }
            .to(now)
        end
      end
    end

    context "when puzzle is nil" do
      let(:puzzle) { nil }

      context "and answer is nil" do
        let(:answer) { nil }

        include_examples :failed_process, errors: [
          "Puzzle can't be blank",
          "Answer can't be blank"
        ]
      end

      context "and answer is present" do
        let(:answer) { "answer" }

        include_examples :failed_process, errors: [
          "Puzzle can't be blank"
        ]
      end
    end

    context "when puzzle is not a Puzzle record" do
      let(:puzzle) { :puzzle }

      context "and answer is nil" do
        let(:answer) { nil }

        include_examples :failed_process, errors: [
          "Puzzle has incompatible type",
          "Answer can't be blank"
        ]
      end

      context "and answer is present" do
        let(:answer) { "answer" }

        include_examples :failed_process, errors: [
          "Puzzle has incompatible type"
        ]
      end
    end

    context "when puzzle is a Puzzle record" do
      let(:puzzle) { create(:puzzle) }

      context "and answer is nil" do
        let(:answer) { nil }

        include_examples :failed_process, errors: [
          "Answer can't be blank"
        ]
      end

      context "and answer is present" do
        let(:answer) { "123" }

        context "and puzzle event is not associated to stats" do
          include_examples :failed_process, errors: [
            "Stats can't be blank"
          ]
        end

        context "and puzzle event is associated to stats" do
          let!(:stats) do
            create(:stats, event: puzzle.event, "day_#{puzzle.day}": progress)
          end

          context "and puzzle is already complete" do
            let(:progress) { 2 }

            include_examples :failed_process, errors: [
              "Puzzle is already complete"
            ]
          end

          context "and puzzle is not already complete" do
            before do
              stub_request(:post, solution_url(puzzle)).to_return(body:)
            end

            let(:attempt) { AocCli::Attempt.last }

            context "and puzzle has no progress" do
              let(:progress) { 0 }

              context "and answer was given too recently" do
                let(:body) do
                  wrap_in_html(<<~HTML)
                    You gave an answer too recently;
                    You have 1m 28s left to wait.
                  HTML
                end

                include_examples :handles_rate_limited_attempt, wait: 1
              end

              context "and answer is incorrect" do
                let(:body) do
                  wrap_in_html(<<~HTML)
                    That's not the right answer; Please wait one minute
                  HTML
                end

                include_examples :handles_incorrect_attempt, wait: 1
              end

              context "and answer is correct" do
                let(:body) do
                  wrap_in_html(<<~HTML)
                    That's the right answer!
                  HTML
                end

                include_examples :handles_correct_attempt, initial: 0
              end
            end

            context "and puzzle has partial progress" do
              let(:progress) { 1 }

              context "and answer was given too recently" do
                let(:body) do
                  wrap_in_html(<<~HTML)
                    You gave an answer too recently;
                    You have 1m 28s left to wait.
                  HTML
                end

                include_examples :handles_rate_limited_attempt, wait: 1
              end

              context "and answer is incorrect" do
                let(:body) do
                  wrap_in_html(<<~HTML)
                    That's not the right answer; Please wait one minute
                  HTML
                end

                include_examples :handles_incorrect_attempt, wait: 1
              end

              context "and answer is correct" do
                let(:body) do
                  wrap_in_html(<<~HTML)
                    That's the right answer!
                  HTML
                end

                include_examples :handles_correct_attempt, initial: 1
              end
            end
          end
        end
      end
    end
  end
end
