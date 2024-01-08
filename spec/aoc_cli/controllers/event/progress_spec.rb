RSpec.describe "/event/progress", :with_temp_dir do
  subject(:make_request) { resolve "/event/progress", params: {} }

  context "when not in an AoC directory" do
    it "renders the expected error" do
      expect { make_request }.to render_errors(
        "Action can't be performed outside Advent of Code directory"
      )
    end

    it "does not render the progress table" do
      expect { make_request }
        .not_to render_component(AocCli::Components::ProgressTable)
    end
  end

  context "when in an event dir" do
    include_context :in_event_dir

    it "does not render errors" do
      expect { make_request }.not_to render_errors
    end

    it "renders the progress table" do
      expect { make_request }
        .to render_component(AocCli::Components::ProgressTable)
        .with(event:)
    end
  end

  context "when in a puzzle dir" do
    include_context :in_puzzle_dir

    it "does not render errors" do
      expect { make_request }.not_to render_errors
    end

    it "renders the progress table" do
      expect { make_request }
        .to render_component(AocCli::Components::ProgressTable)
        .with(event:)
    end
  end
end
