RSpec.describe AocCli::HelpController do
  shared_examples :renders_help_component do
    it "renders the help component" do
      expect { make_request }.to render_component(
        AocCli::Components::HelpComponent
      )
    end
  end

  describe "/" do
    subject(:make_request) { resolve "/", params: {} }

    include_examples :renders_help_component
  end

  describe "/help" do
    subject(:make_request) { resolve "/help", params: {} }

    include_examples :renders_help_component
  end
end
