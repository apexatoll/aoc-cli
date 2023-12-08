RSpec.describe AocCli::Core::AttemptParser do
  subject(:attempt_parser) { described_class.new(response) }

  describe "#to_h" do
    subject(:hash) { attempt_parser.to_h }

    context "when attempting the wrong level" do
      let(:response) do
        <<~TEXT
          You don't seem to be solving the right level.
        TEXT
      end

      it "returns the expected hash" do
        expect(hash).to eq(status: :wrong_level)
      end
    end

    context "when attempt is rate limited" do
      let(:response) do
        <<~TEXT
          You gave an answer too recently; You have 3m 39s left to wait.
        TEXT
      end

      it "returns the expected hash" do
        expect(hash).to eq(status: :rate_limited, wait_time: 3)
      end
    end

    context "when attempt is incorrect" do
      context "and no hint is specified" do
        context "and wait time is one minute" do
          let(:response) do
            <<~TEXT
              That's not the right answer. \
              Please wait one minute before trying again.
            TEXT
          end

          it "returns the expected hash" do
            expect(hash).to eq(status: :incorrect, wait_time: 1)
          end
        end

        context "and wait time is several minutes" do
          let(:response) do
            <<~TEXT
              That's not the right answer. \
              Please wait 5 minutes before trying again.
            TEXT
          end

          it "returns the expected hash" do
            expect(hash).to eq(status: :incorrect, wait_time: 5)
          end
        end
      end

      context "and too low hint is specified" do
        context "and wait time is one minute" do
          let(:response) do
            <<~TEXT
              That's not the right answer; your answer is too low. \
              Please wait one minute before trying again.
            TEXT
          end

          it "returns the expected hash" do
            expect(hash).to eq(
              status: :incorrect, hint: :too_low, wait_time: 1
            )
          end
        end

        context "and wait time is several minutes" do
          let(:response) do
            <<~TEXT
              That's not the right answer; your answer is too low. \
              Please wait 5 minutes before trying again.
            TEXT
          end

          it "returns the expected hash" do
            expect(hash).to eq(
              status: :incorrect, hint: :too_low, wait_time: 5
            )
          end
        end
      end

      context "and too high hint is specified" do
        context "and wait time is one minute" do
          let(:response) do
            <<~TEXT
              That's not the right answer; your answer is too high \
              Please wait one minute before trying again.
            TEXT
          end

          it "returns the expected hash" do
            expect(hash).to eq(
              status: :incorrect, hint: :too_high, wait_time: 1
            )
          end
        end

        context "and wait time is several minutes" do
          let(:response) do
            <<~TEXT
              That's not the right answer; your answer is too high \
              Please wait 5 minutes before trying again.
            TEXT
          end

          it "returns the expected hash" do
            expect(hash).to eq(
              status: :incorrect, hint: :too_high, wait_time: 5
            )
          end
        end
      end
    end

    context "when attempt is correct" do
      let(:response) { "That's the right answer" }

      it "returns the expected hash" do
        expect(hash).to eq(status: :correct)
      end
    end
  end
end
