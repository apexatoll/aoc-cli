RSpec.describe AocCli::Validators::IncludedValidator do
  subject(:model) { model_class.new(attribute:) }

  let(:model_class) do
    Class.new do
      include Kangaru::Validatable

      attr_accessor :attribute

      validates :attribute, included: { in: %i[foo bar baz] }

      def initialize(attribute:)
        @attribute = attribute
      end
    end
  end

  describe "#validate" do
    context "when attribute is not included in the list" do
      let(:attribute) { :invalid }

      include_examples :invalid, errors: ["Attribute is not a valid option"]
    end

    context "when attribute is included in the list" do
      let(:attribute) { :foo }

      include_examples :valid
    end
  end
end
