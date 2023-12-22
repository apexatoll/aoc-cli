RSpec.describe AocCli::Validators::TypeValidator, :with_temp_dir do
  subject(:model) { model_class.new(object:) }

  let(:base_model_class) do
    Class.new do
      include Kangaru::Validatable

      attr_accessor :object

      def initialize(object:)
        @object = object
      end
    end
  end

  let(:string_only_class) do
    Class.new(base_model_class) do
      validates :object, type: { equals: String }
    end
  end

  let(:string_or_symbol_class) do
    Class.new(base_model_class) do
      validates :object, type: { one_of: [String, Symbol] }
    end
  end

  let(:no_options_class) do
    Class.new(base_model_class) do
      validates :object, type: true
    end
  end

  describe "#validate" do
    let(:object) { :foobar }

    context "when no options are declared" do
      let(:model_class) { no_options_class }

      it "raises an error" do
        expect { model.validate }.to raise_error(
          "type must be specified via :equals or :one_of options"
        )
      end
    end

    context "when single type validation is declared" do
      let(:model_class) { string_only_class }

      context "and value is nil" do
        let(:object) { nil }

        include_examples :invalid, errors: ["Object can't be blank"]
      end

      context "and value is present" do
        context "and value is not of specified type" do
          let(:object) { :symbol }

          include_examples :invalid, errors: ["Object has incompatible type"]
        end

        context "and value is of specified type" do
          let(:object) { "string" }

          include_examples :valid
        end
      end
    end

    context "when multiple type validation is declared" do
      let(:model_class) { string_or_symbol_class }

      context "and value is nil" do
        let(:object) { nil }

        include_examples :invalid, errors: ["Object can't be blank"]
      end

      context "and value is present" do
        context "and value is not of specified type" do
          let(:object) { false }

          include_examples :invalid, errors: ["Object has incompatible type"]
        end

        context "and value is one of specified types" do
          let(:object) { :symbol }

          include_examples :valid
        end
      end
    end
  end
end
