RSpec.describe AocCli::Attempt do
  subject(:attempt) { described_class.new(**attributes) }

  let(:attributes) do
    { puzzle:, level:, answer:, status:, hint:, wait_time: }.compact
  end

  let(:puzzle) { create(:puzzle) }

  let(:level) { 1 }

  let(:answer) { 100 }

  let(:status) { :correct }

  let(:hint) { nil }

  let(:wait_time) { nil }

  describe "validations" do
    describe ":puzzle" do
      context "when nil" do
        let(:puzzle) { nil }

        include_examples :invalid, errors: ["Puzzle can't be blank"]
      end

      context "when present" do
        let(:puzzle) { create(:puzzle) }

        include_examples :valid
      end
    end

    describe ":level" do
      context "when nil" do
        let(:level) { nil }

        include_examples :invalid, errors: ["Level can't be blank"]
      end

      context "when not an integer" do
        let(:level) { :foobar }

        include_examples :invalid, errors: ["Level is not an integer"]
      end

      context "when lower than 1" do
        let(:level) { 0 }

        include_examples :invalid, errors: ["Level is too small"]
      end

      context "when greater than 2" do
        let(:level) { 3 }

        include_examples :invalid, errors: ["Level is too large"]
      end

      context "when 1" do
        let(:level) { 1 }

        include_examples :valid
      end

      context "when 2" do
        let(:level) { 2 }

        include_examples :valid
      end
    end

    describe ":answer" do
      context "when nil" do
        let(:answer) { nil }

        include_examples :invalid, errors: ["Answer can't be blank"]
      end

      context "when an integer" do
        let(:answer) { 123 }

        include_examples :valid
      end

      context "when a string" do
        let(:answer) { "foobar" }

        include_examples :valid
      end
    end

    describe ":status" do
      context "when nil" do
        let(:status) { nil }

        include_examples :invalid, errors: ["Status is not a valid option"]
      end

      context "when invalid" do
        let(:status) { :invalid }

        include_examples :invalid, errors: ["Status is not a valid option"]
      end

      context "when :wrong_level" do
        let(:status) { :wrong_level }

        include_examples :valid
      end

      context "when :rate_limited" do
        let(:status) { :rate_limited }

        let(:wait_time) { 1 }

        include_examples :valid
      end

      context "when :incorrect" do
        let(:status) { :incorrect }

        let(:wait_time) { 1 }

        include_examples :valid
      end

      context "when :correct" do
        let(:status) { :correct }

        include_examples :valid
      end
    end

    describe ":hint" do
      context "when status is :wrong_level" do
        let(:status) { :wrong_level }

        context "and hint is nil" do
          let(:hint) { nil }

          include_examples :valid
        end

        context "and hint is present" do
          let(:hint) { :too_low }

          include_examples :invalid, errors: ["Hint is not expected"]
        end
      end

      context "when status is :rate_limited" do
        let(:status) { :rate_limited }

        let(:wait_time) { 1 }

        context "and hint is nil" do
          let(:hint) { nil }

          include_examples :valid
        end

        context "and hint is present" do
          let(:hint) { :too_low }

          include_examples :invalid, errors: ["Hint is not expected"]
        end
      end

      context "when status is :correct" do
        let(:status) { :correct }

        context "and hint is nil" do
          let(:hint) { nil }

          include_examples :valid
        end

        context "and hint is present" do
          let(:hint) { :too_low }

          include_examples :invalid, errors: ["Hint is not expected"]
        end
      end

      context "when status is :incorrect" do
        let(:status) { :incorrect }

        let(:wait_time) { 1 }

        context "and hint is nil" do
          let(:hint) { nil }

          include_examples :valid
        end

        context "and hint is invalid" do
          let(:hint) { :invalid }

          include_examples :invalid, errors: ["Hint is not a valid option"]
        end

        context "and hint is :too_low" do
          let(:hint) { :too_low }

          include_examples :valid
        end

        context "and hint is :too_high" do
          let(:hint) { :too_high }

          include_examples :valid
        end
      end
    end

    describe ":wait_time" do
      context "when status is :rate_limited" do
        let(:status) { :rate_limited }

        context "and wait_time is nil" do
          let(:wait_time) { nil }

          include_examples :invalid, errors: ["Wait time is not an integer"]
        end

        context "and wait_time is not an integer" do
          let(:wait_time) { :foobar }

          include_examples :invalid, errors: ["Wait time is not an integer"]
        end

        context "and wait_time is an integer" do
          let(:wait_time) { 3 }

          include_examples :valid
        end
      end

      context "when status is :wrong_level" do
        let(:status) { :wrong_level }

        context "and wait_time is nil" do
          let(:wait_time) { nil }

          include_examples :valid
        end

        context "and wait_time is an integer" do
          let(:wait_time) { 10 }

          include_examples :invalid, errors: ["Wait time is not expected"]
        end
      end

      context "when status is :incorrect" do
        let(:status) { :incorrect }

        context "and wait_time is nil" do
          let(:wait_time) { nil }

          include_examples :invalid, errors: ["Wait time is not an integer"]
        end

        context "and wait_time is not an integer" do
          let(:wait_time) { :foobar }

          include_examples :invalid, errors: ["Wait time is not an integer"]
        end

        context "and wait_time is an integer" do
          let(:wait_time) { 3 }

          include_examples :valid
        end
      end

      context "when status is :correct" do
        let(:status) { :correct }

        context "and wait_time is nil" do
          let(:wait_time) { nil }

          include_examples :valid
        end

        context "and wait_time is an integer" do
          let(:wait_time) { 10 }

          include_examples :invalid, errors: ["Wait time is not expected"]
        end
      end
    end
  end
end
