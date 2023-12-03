RSpec.describe AocCli::Stats do
  subject(:stats) { described_class.new(**attributes) }

  let(:attributes) { { event:, **stats_hash } }

  let(:event) { AocCli::Event.create(year: 2020) }

  let(:stats_hash) { 1.upto(25).to_h { |i| [:"day_#{i}", 0] } }

  describe "validations" do
    shared_examples :validates_day do |day|
      describe ":day_#{day}" do
        before { stats_hash.merge!("day_#{day}": value) }

        context "when nil" do
          let(:value) { nil }

          include_examples :invalid, errors: ["Day #{day} can't be blank"]
        end

        context "when not an integer" do
          let(:value) { :foobar }

          include_examples :invalid, errors: ["Day #{day} is not an integer"]
        end

        context "when 0" do
          let(:value) { 0 }

          include_examples :valid
        end

        context "when 1" do
          let(:value) { 1 }

          include_examples :valid
        end

        context "when 2" do
          let(:value) { 2 }

          include_examples :valid
        end

        context "when 3" do
          let(:value) { 3 }

          include_examples :invalid, errors: ["Day #{day} is too large"]
        end
      end
    end

    describe ":event" do
      context "when nil" do
        let(:event) { nil }

        include_examples :invalid, errors: ["Event can't be blank"]
      end

      context "when present" do
        let(:event) { AocCli::Event.create(year: 2020) }

        include_examples :valid
      end
    end

    1.upto(25) do |day|
      include_examples :validates_day, day
    end
  end
end
