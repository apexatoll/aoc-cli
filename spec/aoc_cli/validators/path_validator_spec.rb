RSpec.describe AocCli::Validators::PathValidator, :with_temp_dir do
  subject(:model) { model_class.new(path:) }

  let(:path) { temp_path("foobar").to_s }

  let(:base_model_class) do
    Class.new do
      include Kangaru::Validatable

      attr_accessor :path

      def initialize(path:)
        @path = path
      end
    end
  end

  let(:path_does_not_exist_class) do
    Class.new(base_model_class) do
      validates :path, path: { exists: false }
    end
  end

  let(:path_exists_class) do
    Class.new(base_model_class) do
      validates :path, path: { exists: true }
    end
  end

  let(:no_options_class) do
    Class.new(base_model_class) do
      validates :path, path: true
    end
  end

  shared_context :path_exists do
    before { File.write(path, "contents") }
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

    shared_examples :validates_path_does_not_exist do
      context "and path is nil" do
        let(:path) { nil }

        include_examples :invalid, errors: ["Path can't be blank"]
      end

      context "and path is set" do
        context "and path does not exist" do
          include_examples :valid
        end

        context "and path exists" do
          include_context :path_exists

          include_examples :invalid, errors: ["Path already exists"]
        end
      end
    end

    shared_examples :validates_path_exists do
      context "and path is nil" do
        let(:path) { nil }

        include_examples :invalid, errors: ["Path can't be blank"]
      end

      context "and path is set" do
        context "and path does not exist" do
          include_examples :invalid, errors: ["Path does not exist"]
        end

        context "and path exists" do
          include_context :path_exists

          include_examples :valid
        end
      end
    end

    context "when exists is set to false" do
      let(:model_class) { path_does_not_exist_class }

      include_examples :validates_path_does_not_exist
    end

    context "when exists is set to true" do
      let(:model_class) { path_exists_class }

      include_examples :validates_path_exists
    end

    context "when exists is not set" do
      let(:model_class) { no_options_class }

      include_examples :validates_path_exists
    end
  end
end
