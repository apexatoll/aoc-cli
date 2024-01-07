RSpec.describe AocCli::Helpers::ErrorHelper do
  describe "#render_error!" do
    subject(:render_error!) { helper.render_error!(message) }

    let(:message) { "This is an error" }

    it "renders the error" do
      expect { render_error! }.to render_errors(message)
    end

    it "returns a falsey value" do
      expect(render_error!).to be_falsey
    end
  end

  describe "#render_model_errors!" do
    subject(:render_model_errors!) { helper.render_model_errors!(model) }

    let(:model) { Struct.new(:errors).new([error]) }

    let(:error) { Struct.new(:full_message).new(message) }

    let(:message) { "This is an error" }

    it "renders the error" do
      expect { render_model_errors! }.to render_errors(message)
    end

    it "returns a falsey value" do
      expect(render_model_errors!).to be_falsey
    end
  end
end
