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

    describe "handling --help flag" do
      subject(:make_request) { resolve "/test/foobar", params: }

      let(:params) { { help:, param: }.compact }

      let(:param) { nil }

      let(:controller_class) do
        Class.new(described_class) { def foobar; end }
      end

      let(:help_controller_class) do
        Class.new(described_class) { def foobar; end }
      end

      before do
        stub_const "AocCli::Help::TestController", help_controller_class
      end

      context "when help flag is not passed" do
        let(:help) { nil }

        it "does not redirect to the help controller action" do
          expect { make_request }.not_to redirect_to("/help/test/foobar")
        end
      end

      context "when help flag is passed" do
        let(:help) { true }

        context "and no other params are specified" do
          let(:param) { nil }

          it "redirects to the help controller action without params" do
            expect { make_request }
              .to redirect_to("/help/test/foobar")
              .with_params({})
          end
        end

        context "and other params are specified" do
          let(:param) { "value" }

          it "redirects to the help controller action with param" do
            expect { make_request }
              .to redirect_to("/help/test/foobar")
              .with_params(param:)
          end
        end
      end
    end
  end
end
