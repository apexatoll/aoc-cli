# vi: ft=rspec

RSpec.shared_examples :invalid do |options|
  let(:expected_errors) { options[:errors] }
  let(:actual_errors)   { subject.errors.map(&:full_message) }

  it "is not valid" do
    expect(subject).not_to be_valid
  end

  it "sets the expected error messages" do
    subject.validate
    expect(actual_errors).to match_array(expected_errors)
  end
end

RSpec.shared_examples :valid do
  it "is valid" do
    expect(subject).to be_valid
  end
end
