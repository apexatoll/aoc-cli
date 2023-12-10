RSpec.describe AocCli::Helpers::ErrorsHelper do
  subject(:target) { Class.new { include AocCli::Helpers::ErrorsHelper }.new }

  let(:errors_component) do
    instance_double(AocCli::Components::ErrorsComponent, render: nil)
  end

  before do
    allow(AocCli::Components::ErrorsComponent)
      .to receive(:from_model)
      .and_return(errors_component)
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
