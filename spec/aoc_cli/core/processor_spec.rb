RSpec.describe AocCli::Core::Processor do
  subject(:processor) { processor_class.new(attribute:) }

  let(:processor_class) do
    Class.new(described_class) do
      attr_accessor :attribute

      validates :attribute, required: true

      def run = nil
    end
  end

  describe "#run!" do
    subject(:run!) { processor.run! }

    context "when processor is not valid" do
      let(:attribute) { nil }

      it "raises an error" do
        expect { run! }.to raise_error(described_class::Error)
      end

      it "sets the processor reference" do
        run!
      rescue described_class::Error => e
        expect(e.processor).to eq(processor)
      end
    end

    context "when processor is valid" do
      let(:attribute) { true }

      it "does not raise an error" do
        expect { run! }.not_to raise_error
      end
    end
  end
end
