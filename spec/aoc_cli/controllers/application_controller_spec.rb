RSpec.describe AocCli::ApplicationController do
  describe "#execute" do
    before do
      stub_const "AocCli::TestController", controller_class
    end

    describe "handling processor errors" do
      subject(:make_request) { resolve "/test/run_processor", params: }

      let(:params) { { attribute: }.compact }

      let(:controller_class) do
        Class.new(described_class) do
          def run_processor
            AocCli::Processors::TestProcessor.run!(
              attribute: params[:attribute]
            )
          end
        end
      end

      let(:processor_class) do
        Class.new(AocCli::Core::Processor) do
          include Kangaru::Attributable

          attr_accessor :attribute

          validates :attribute, required: true

          def run
            true
          end
        end
      end

      before do
        stub_const "AocCli::Processors::TestProcessor", processor_class
      end

      context "and processor error is not raised" do
        let(:attribute) { "attribute" }

        it "does not render any errors" do
          expect { make_request }.not_to render_errors
        end
      end

      context "and processor error is raised" do
        let(:attribute) { nil }

        it "renders the expected errors" do
          expect { make_request }.to render_errors("Attribute can't be blank")
        end
      end
    end
  end
end
