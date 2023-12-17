RSpec.describe AocCli::Presenters::AttemptPresenter do
  subject(:presenter) { described_class.new(attempt) }

  let(:attempt) { create(:attempt, trait) }

  describe "#status" do
    subject(:status) { presenter.status }

    context "when :wrong_level" do
      let(:trait) { :wrong_level }

      it "returns the expected text" do
        expect(status).to eq("Wrong level")
      end
    end

    context "when :rate_limited" do
      let(:trait) { :rate_limited }

      it "returns the expected text" do
        expect(status).to eq("Rate limited")
      end
    end

    context "when :incorrect" do
      let(:trait) { :incorrect }

      it "returns the expected text" do
        expect(status).to eq("Incorrect")
      end
    end

    context "when :correct" do
      let(:trait) { :correct }

      it "returns the expected text" do
        expect(status).to eq("Correct")
      end
    end
  end

  describe "#hint" do
    subject(:hint) { presenter.hint }

    context "when :wrong_level" do
      let(:trait) { :wrong_level }

      it "returns the expected text" do
        expect(hint).to eq("-")
      end
    end

    context "when :rate_limited" do
      let(:trait) { :rate_limited }

      it "returns the expected text" do
        expect(hint).to eq("-")
      end
    end

    context "when :incorrect" do
      let(:trait) { :incorrect }

      it "returns the expected text" do
        expect(hint).to eq("-")
      end
    end

    context "when :too_low" do
      let(:trait) { :too_low }

      it "returns the expected text" do
        expect(hint).to eq("Too low")
      end
    end

    context "when :too_high" do
      let(:trait) { :too_high }

      it "returns the expected text" do
        expect(hint).to eq("Too high")
      end
    end

    context "when :correct" do
      let(:trait) { :correct }

      it "returns the expected text" do
        expect(hint).to eq("-")
      end
    end
  end
end
