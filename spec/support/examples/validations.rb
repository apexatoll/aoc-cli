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

RSpec.shared_examples :validates_event_year do
  context "when nil" do
    let(:year) { nil }

    include_examples :invalid, errors: ["Year can't be blank"]
  end

  context "when not an integer" do
    let(:year) { :foobar }

    include_examples :invalid, errors: ["Year is not an integer"]
  end

  context "when before first event" do
    let(:year) { 2014 }

    include_examples :invalid, errors: [
      "Year is before first Advent of Code event (2015)"
    ]
  end

  context "when after most recent event" do
    let(:year) { 2030 }

    include_examples :invalid, errors: ["Year is in the future"]
  end

  context "when valid" do
    let(:year) { 2023 }

    include_examples :valid
  end
end

RSpec.shared_examples :validates_puzzle_day do
  context "when nil" do
    let(:day) { nil }

    include_examples :invalid, errors: ["Day can't be blank"]
  end

  context "when not an integer" do
    let(:day) { :day }

    include_examples :invalid, errors: ["Day is not an integer"]
  end

  context "when negative" do
    let(:day) { -1 }

    include_examples :invalid, errors: ["Day is too small"]
  end

  context "when too low" do
    let(:day) { 0 }

    include_examples :invalid, errors: ["Day is too small"]
  end

  context "when too high" do
    let(:day) { 26 }

    include_examples :invalid, errors: ["Day is too large"]
  end

  context "when valid" do
    let(:day) { 1 }

    include_examples :valid
  end
end
