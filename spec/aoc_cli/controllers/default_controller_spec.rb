RSpec.describe AocCli::DefaultController do
  describe "/" do
    subject(:make_request) { resolve "/", params: {} }

    it "renders the docs component" do
      expect { make_request }.to render_component(
        AocCli::Components::DocsComponent
      )
    end
  end

  describe "/help" do
    subject(:make_request) { resolve "/help", params: {} }

    it "renders the docs component" do
      expect { make_request }.to render_component(
        AocCli::Components::DocsComponent
      )
    end
  end
end
