RSpec.describe AocCli::Validators::CollectionTypeValidator do
  subject(:model) { model_class.new(collection:) }

  let(:collection) { nil }

  let(:base_model_class) do
    Class.new do
      include Kangaru::Attributable
      include Kangaru::Validatable

      attr_accessor :collection
    end
  end

  describe "#validate" do
    context "when no validation rules are specified" do
      let(:model_class) do
        Class.new(base_model_class) do
          validates :collection, collection_type: true
        end
      end

      it "raises an error" do
        expect { model.validate }.to raise_error(
          "Collection type rule must be one of [:all, :any, :none]"
        )
      end
    end

    context "when multiple validation rules are specified" do
      let(:model_class) do
        Class.new(base_model_class) do
          validates :collection, collection_type: { all: String, none: String }
        end
      end

      it "raises an error" do
        expect { model.validate }.to raise_error(
          "Collection type rule must be one of [:all, :any, :none]"
        )
      end
    end

    context "when single validation rule is specified" do
      describe ":all" do
        let(:model_class) do
          Class.new(base_model_class) do
            validates :collection, collection_type: { all: Symbol }
          end
        end

        context "and value is nil" do
          let(:collection) { nil }

          include_examples :invalid, errors: [
            "Collection can't be blank"
          ]
        end

        context "and value is not an array" do
          let(:collection) { "Hello world" }

          include_examples :invalid, errors: [
            "Collection is not an array"
          ]
        end

        context "and value is an array" do
          let(:collection) { [element_one, element_two] }

          context "and no elements are the specified type" do
            let(:element_one) { "foo" }
            let(:element_two) { "bar" }

            include_examples :invalid, errors: [
              "Collection elements have incompatible types"
            ]
          end

          context "and some elements are the specified type" do
            let(:element_one) { :foo }
            let(:element_two) { "bar" }

            include_examples :invalid, errors: [
              "Collection elements have incompatible types"
            ]
          end

          context "and all elements are the specified type" do
            let(:element_one) { :foo }
            let(:element_two) { :bar }

            include_examples :valid
          end
        end
      end

      describe ":any" do
        let(:model_class) do
          Class.new(base_model_class) do
            validates :collection, collection_type: { any: Symbol }
          end
        end

        context "and value is nil" do
          let(:collection) { nil }

          include_examples :invalid, errors: [
            "Collection can't be blank"
          ]
        end

        context "and value is not an array" do
          let(:collection) { "Hello world" }

          include_examples :invalid, errors: [
            "Collection is not an array"
          ]
        end

        context "and value is an array" do
          let(:collection) { [element_one, element_two] }

          context "and no elements are the specified type" do
            let(:element_one) { "foo" }
            let(:element_two) { "bar" }

            include_examples :invalid, errors: [
              "Collection elements have incompatible types"
            ]
          end

          context "and some elements are the specified type" do
            let(:element_one) { :foo }
            let(:element_two) { "bar" }

            include_examples :valid
          end

          context "and all elements are the specified type" do
            let(:element_one) { :foo }
            let(:element_two) { :bar }

            include_examples :valid
          end
        end
      end

      describe ":none" do
        let(:model_class) do
          Class.new(base_model_class) do
            validates :collection, collection_type: { none: Symbol }
          end
        end

        context "and value is nil" do
          let(:collection) { nil }

          include_examples :invalid, errors: [
            "Collection can't be blank"
          ]
        end

        context "and value is not an array" do
          let(:collection) { "Hello world" }

          include_examples :invalid, errors: [
            "Collection is not an array"
          ]
        end

        context "and value is an array" do
          let(:collection) { [element_one, element_two] }

          context "and no elements are the specified type" do
            let(:element_one) { "foo" }
            let(:element_two) { "bar" }

            include_examples :valid
          end

          context "and some elements are the specified type" do
            let(:element_one) { :foo }
            let(:element_two) { "bar" }

            include_examples :invalid, errors: [
              "Collection elements have incompatible types"
            ]
          end

          context "and all elements are the specified type" do
            let(:element_one) { :foo }
            let(:element_two) { :bar }

            include_examples :invalid, errors: [
              "Collection elements have incompatible types"
            ]
          end
        end
      end
    end
  end
end
