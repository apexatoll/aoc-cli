RSpec.describe AocCli::Processors::ResourceAttacher, :with_temp_dir do
  let(:existing_path) { temp_dir }
  let(:non_existing_path) { temp_path("foobar").to_s }

  describe ".run!" do
    subject(:run!) { described_class.run!(resource:, path:) }

    context "when resource is nil" do
      let(:resource) { nil }

      context "and path does not exist" do
        let(:path) { non_existing_path }

        include_examples :failed_process, errors: [
          "Resource can't be blank",
          "Path does not exist"
        ]
      end

      context "and path exists" do
        let(:path) { existing_path }

        include_examples :failed_process, errors: ["Resource can't be blank"]
      end
    end

    context "when resource is neither an event or a puzzle" do
      let(:resource) { :foobar }

      context "and path does not exist" do
        let(:path) { non_existing_path }

        include_examples :failed_process, errors: [
          "Resource has incompatible type",
          "Path does not exist"
        ]
      end

      context "and path exists" do
        let(:path) { existing_path }

        include_examples :failed_process, errors: [
          "Resource has incompatible type"
        ]
      end
    end

    context "when resource is an event" do
      let(:resource) { create(:event) }

      context "and path does not exist" do
        let(:path) { non_existing_path }

        include_examples :failed_process, errors: ["Path does not exist"]
      end

      context "and path exists" do
        let(:path) { existing_path }

        context "and event is not already located elsewhere" do
          it "does not raise an Error" do
            expect { run! }.not_to raise_error
          end

          it "creates a Location record" do
            expect { run! }
              .to create_model(AocCli::Location)
              .with_attributes(resource:, path:)
          end

          it "returns the Location" do
            expect(run!).to eq(AocCli::Location.last)
          end
        end

        context "and event is already located at given path" do
          let!(:location) do
            create(:location, :year_dir, path:, event: resource)
          end

          it "does not update the Location record" do
            expect { run! }.not_to change { location.reload.values }
          end

          it "returns the Location" do
            expect(run!).to eq(location)
          end
        end

        context "and event is already located elsewhere" do
          let!(:location) { create(:location, :year_dir, event: resource) }

          it "updates the Location record path" do
            expect { run! }.to change { location.reload.path }.to(path)
          end

          it "returns the Location" do
            expect(run!).to eq(location.reload)
          end
        end
      end
    end

    context "when resource is a puzzle" do
      let(:resource) { create(:puzzle) }

      context "and path does not exist" do
        let(:path) { non_existing_path }

        include_examples :failed_process, errors: ["Path does not exist"]
      end

      context "and path exists" do
        let(:path) { existing_path }

        context "and puzzle is not already located elsewhere" do
          it "does not raise an Error" do
            expect { run! }.not_to raise_error
          end

          it "creates a Location record" do
            expect { run! }
              .to create_model(AocCli::Location)
              .with_attributes(resource:, path:)
          end

          it "returns the Location" do
            expect(run!).to eq(AocCli::Location.last)
          end
        end

        context "and puzzle is already located at given path" do
          let!(:location) do
            create(:location, :puzzle_dir, path:, puzzle: resource)
          end

          it "does not raise any errors" do
            expect { run! }.not_to raise_error
          end

          it "does not update the Location record" do
            expect { run! }.not_to change { location.reload.values }
          end

          it "returns the Location" do
            expect(run!).to eq(location)
          end
        end

        context "and puzzle is already located elsewhere" do
          let!(:location) { create(:location, :puzzle_dir, puzzle: resource) }

          it "updates the Location record path" do
            expect { run! }
              .to change { location.reload.path }
              .to(path)
          end

          it "returns the Location" do
            expect(run!).to eq(location.reload)
          end
        end
      end
    end
  end
end
