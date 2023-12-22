RSpec.shared_examples :failed_process do |options|
  let(:errors) { options[:errors] }

  def actual_errors(processor)
    processor.errors.map(&:full_message)
  end

  it "raises an error" do
    expect { subject }.to raise_error(described_class::Error)
  end

  it "sets the expected errors" do
    subject
  rescue described_class::Error => e
    expect(actual_errors(e.processor)).to eq(errors)
  end
end
