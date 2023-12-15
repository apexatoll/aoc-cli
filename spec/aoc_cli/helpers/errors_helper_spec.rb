RSpec.describe AocCli::Helpers::ErrorsHelper do
  subject(:target) { Class.new { include AocCli::Helpers::ErrorsHelper }.new }

  let(:errors_component) do
    instance_double(AocCli::Components::ErrorsComponent, render: nil)
  end

  before do
    allow(AocCli::Components::ErrorsComponent).to receive_messages(
      new: errors_component,
      from_model: errors_component
    )
  end

  describe "#render_errors!" do
    subject(:render_errors!) { target.render_errors!(*errors) }

    let(:errors) { ["Foo Error", "Bar Error"] }

    it "builds an errors component" do
      render_errors!

      expect(AocCli::Components::ErrorsComponent)
        .to have_received(:new)
        .with(*errors)
        .once
    end

    it "renders the component" do
      render_errors!
      expect(errors_component).to have_received(:render).once
    end

    it "returns false" do
      expect(render_errors!).to be(false)
    end
  end

  describe "#render_model_errors!" do
    subject(:render_model_errors!) { target.render_model_errors!(model) }

    let(:model) { :model }

    it "builds an error component for the model" do
      render_model_errors!

      expect(AocCli::Components::ErrorsComponent)
        .to have_received(:from_model)
        .with(model)
        .once
    end

    it "renders the component" do
      render_model_errors!
      expect(errors_component).to have_received(:render).once
    end

    it "returns false" do
      expect(render_model_errors!).to be(false)
    end
  end
end
