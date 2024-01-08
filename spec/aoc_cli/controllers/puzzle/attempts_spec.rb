RSpec.describe "/puzzle/attempts", :with_temp_dir do
  subject(:make_request) { resolve "/puzzle/attempts", params: {} }

  context "when not in an AoC directory" do
    it "does not render the attempts table" do
      expect { make_request }
        .not_to render_component(AocCli::Components::AttemptsTable)
    end

    it "renders the expected error" do
      expect { make_request }.to render_errors(
        "Action can't be performed outside puzzle directory"
      )
    end
  end

  context "when in an event directory" do
    include_context :in_event_dir

    it "does not render the attempts table" do
      expect { make_request }
        .not_to render_component(AocCli::Components::AttemptsTable)
    end

    it "renders the expected error" do
      expect { make_request }.to render_errors(
        "Action can't be performed outside puzzle directory"
      )
    end
  end

  context "when in a puzzle directory" do
    include_context :in_puzzle_dir

    it "does not render errors" do
      expect { make_request }.not_to render_errors
    end

    it "renders the attempts table" do
      expect { make_request }
        .to render_component(AocCli::Components::AttemptsTable)
        .with(puzzle:)
    end
  end
end
