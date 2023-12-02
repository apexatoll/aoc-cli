RSpec.describe AocCli::Validators::IntegerValidator do
  subject(:model) { model_class.new(attribute:) }

  let(:base_model_class) do
    Class.new do
      include Kangaru::Validatable

      attr_accessor :attribute

      def initialize(attribute:)
        @attribute = attribute
      end
    end
  end

  describe "#validate" do
    subject(:validate) { model.validate }

    shared_examples :invalid do |options|
      let(:errors) { options[:errors] }

      it "is not valid" do
        expect(model).not_to be_valid
      end

      it "sets the expected errors" do
        validate
        expect(model.errors.map(&:full_message)).to match_array(errors)
      end
    end

    shared_examples :valid do
      it "is valid" do
        expect(model).to be_valid
      end
    end

    describe ":between" do
      let(:model_class) do
        Class.new(base_model_class) do
          validates :attribute, integer: { between: 5..10 }
        end
      end

      context "when nil" do
        let(:attribute) { nil }

        include_examples :invalid, errors: ["Attribute can't be blank"]
      end

      context "when not an integer" do
        let(:attribute) { :attribute }

        include_examples :invalid, errors: ["Attribute is not an integer"]
      end

      context "when integer is less than minimum in range" do
        let(:attribute) { 4 }

        include_examples :invalid, errors: ["Attribute is too small"]
      end

      context "when integer is more than maximum in range" do
        let(:attribute) { 11 }

        include_examples :invalid, errors: ["Attribute is too large"]
      end

      context "when integer is in range" do
        let(:attribute) { 8 }

        include_examples :valid
      end
    end
  end
end
