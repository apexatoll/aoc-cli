RSpec.describe AocCli::Helpers::LocationHelper, :with_temp_dir do
  around { |spec| Dir.chdir(temp_dir) { spec.run } }

  describe "#current_path" do
    subject(:path) { helper.current_path }

    it "returns the current path" do
      expect(path).to eq(temp_dir)
    end
  end

  describe "#current_location" do
    subject(:current_location) { helper.current_location }

    context "when not in an AoC directory" do
      it "returns nil" do
        expect(current_location).to be_nil
      end
    end

    context "when in an event directory" do
      include_context :in_event_dir

      it "returns the location" do
        expect(current_location).to eq(location)
      end
    end

    context "when in a puzzle directory" do
      include_context :in_puzzle_dir

      it "returns the location" do
        expect(current_location).to eq(location)
      end
    end
  end

  describe "#current_event" do
    subject(:current_event) { helper.current_event }

    context "when not in an AoC directory" do
      it "returns nil" do
        expect(current_event).to be_nil
      end
    end

    context "when in an event directory" do
      include_context :in_event_dir

      it "returns the associated event" do
        expect(current_event).to eq(event)
      end
    end

    context "when in a puzzle directory" do
      include_context :in_puzzle_dir

      it "returns the associated event" do
        expect(current_event).to eq(event)
      end
    end
  end

  describe "#current_puzzle" do
    subject(:current_puzzle) { helper.current_puzzle }

    context "when not in an AoC directory" do
      it "returns nil" do
        expect(current_puzzle).to be_nil
      end
    end

    context "when in an event directory" do
      include_context :in_event_dir

      it "returns nil" do
        expect(current_puzzle).to be_nil
      end
    end

    context "when in a puzzle directory" do
      include_context :in_puzzle_dir

      it "returns the associated puzzle" do
        expect(current_puzzle).to eq(puzzle)
      end
    end
  end

  describe "#ensure_in_event_dir!" do
    subject(:ensure_in_event_dir!) { helper.ensure_in_event_dir! }

    context "when not in aoc directory" do
      it "renders the expected error" do
        expect { ensure_in_event_dir! }.to render_errors(
          "Action can't be performed outside event directory"
        )
      end

      it "returns false" do
        expect(ensure_in_event_dir!).to be(false)
      end
    end

    context "when in event directory" do
      include_context :in_event_dir

      it "does not render any errors" do
        expect { ensure_in_event_dir! }.not_to render_errors
      end

      it "returns a truthy value" do
        expect(ensure_in_event_dir!).to be_truthy
      end
    end

    context "when in puzzle directory" do
      include_context :in_puzzle_dir

      it "renders the expected error" do
        expect { ensure_in_event_dir! }.to render_errors(
          "Action can't be performed outside event directory"
        )
      end

      it "returns false" do
        expect(ensure_in_event_dir!).to be(false)
      end
    end
  end

  describe "#ensure_in_puzzle_dir!" do
    subject(:ensure_in_puzzle_dir!) { helper.ensure_in_puzzle_dir! }

    context "when not in aoc directory" do
      it "renders the expected error" do
        expect { ensure_in_puzzle_dir! }.to render_errors(
          "Action can't be performed outside puzzle directory"
        )
      end

      it "returns false" do
        expect(ensure_in_puzzle_dir!).to be(false)
      end
    end

    context "when in event directory" do
      include_context :in_event_dir

      it "renders the expected error" do
        expect { ensure_in_puzzle_dir! }.to render_errors(
          "Action can't be performed outside puzzle directory"
        )
      end

      it "returns false" do
        expect(ensure_in_puzzle_dir!).to be(false)
      end
    end

    context "when in puzzle directory" do
      include_context :in_puzzle_dir

      it "does not render any errors" do
        expect { ensure_in_puzzle_dir! }.not_to render_errors
      end

      it "returns a truthy value" do
        expect(ensure_in_puzzle_dir!).to be_truthy
      end
    end
  end

  describe "#ensure_in_aoc_dir!" do
    subject(:ensure_in_aoc_dir!) { helper.ensure_in_aoc_dir! }

    context "when not in aoc directory" do
      it "renders the expected error" do
        expect { ensure_in_aoc_dir! }.to render_errors(
          "Action can't be performed outside Advent of Code directory"
        )
      end

      it "returns false" do
        expect(ensure_in_aoc_dir!).to be(false)
      end
    end

    context "when in event directory" do
      include_context :in_event_dir

      it "does not render any errors" do
        expect { ensure_in_aoc_dir! }.not_to render_errors
      end

      it "returns a truthy value" do
        expect(ensure_in_aoc_dir!).to be_truthy
      end
    end

    context "when in puzzle directory" do
      include_context :in_puzzle_dir

      it "does not render any errors" do
        expect { ensure_in_aoc_dir! }.not_to render_errors
      end

      it "returns a truthy value" do
        expect(ensure_in_aoc_dir!).to be_truthy
      end
    end
  end

  describe "#ensure_not_in_aoc_dir!" do
    subject(:ensure_not_in_aoc_dir!) { helper.ensure_not_in_aoc_dir! }

    context "when not in aoc directory" do
      it "does not render any errors" do
        expect { ensure_not_in_aoc_dir! }.not_to render_errors
      end

      it "returns a truthy value" do
        expect(ensure_not_in_aoc_dir!).to be_truthy
      end
    end

    context "when in event directory" do
      include_context :in_event_dir

      it "renders the expected error" do
        expect { ensure_not_in_aoc_dir! }.to render_errors(
          "Action can't be performed from Advent of Code directory"
        )
      end

      it "returns false" do
        expect(ensure_not_in_aoc_dir!).to be(false)
      end
    end

    context "when in puzzle directory" do
      include_context :in_puzzle_dir

      it "renders the expected error" do
        expect { ensure_not_in_aoc_dir! }.to render_errors(
          "Action can't be performed from Advent of Code directory"
        )
      end

      it "returns false" do
        expect(ensure_not_in_aoc_dir!).to be(false)
      end
    end
  end
end
