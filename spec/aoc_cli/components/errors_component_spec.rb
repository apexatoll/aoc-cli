RSpec.describe AocCli::Components::ErrorsComponent do
  subject(:errors_component) { described_class.new(*messages) }

  describe "#render" do
    subject(:render) { errors_component.render }

    context "when no messages are set" do
      let(:messages) { [] }

      it "does not render the component to stdout" do
        expect { render }.not_to output.to_stdout
      end
    end

    context "when one message is set" do
      let(:messages) { ["Attribute is not an integer"] }

      it "renders the error inline to stdout" do
        expect { render }.to output(<<~TEXT).to_stdout
          #{'Error'.red}: Attribute is not an integer
        TEXT
      end
    end

    context "when multiple messages are set" do
      let(:messages) do
        [
          "Attribute can't be blank",
          "Attribute is not an integer"
        ]
      end

      it "renders the error list to stdout" do
        expect { render }.to output(<<~TEXT).to_stdout
          #{'Error'.red}:
            • Attribute can't be blank
            • Attribute is not an integer
        TEXT
      end
    end
  end

  describe ".from_model" do
    subject(:errors_component) { described_class.from_model(model) }

    let(:model) { model_class.new(foo:, bar:) }

    let(:model_class) do
      Class.new do
        include Kangaru::Validatable

        attr_reader :foo, :bar

        def initialize(foo:, bar:)
          @foo = foo
          @bar = bar
        end

        validates :foo, integer: true
        validates :bar, integer: true
      end
    end

    before { model.validate }

    shared_examples :builds_component do |options|
      let(:messages) { options[:messages] }

      it "returns an errors component" do
        expect(errors_component).to be_a(described_class)
      end

      it "sets the expected messages" do
        expect(errors_component.messages).to eq(messages)
      end
    end

    context "when model does not have any errors" do
      let(:foo) { 99 }
      let(:bar) { 21 }

      include_examples :builds_component, messages: []
    end

    context "when model has one error" do
      let(:foo) { :foo }
      let(:bar) { 100 }

      include_examples :builds_component, messages: [
        "Foo is not an integer"
      ]
    end

    context "when model has multiple errors" do
      let(:foo) { nil }
      let(:bar) { :bar }

      include_examples :builds_component, messages: [
        "Foo can't be blank",
        "Bar is not an integer"
      ]
    end
  end
end
