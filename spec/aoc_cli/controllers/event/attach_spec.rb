RSpec.describe "/event/attach/:year", :with_temp_dir do
  subject(:make_request) { resolve path, params: }

  let(:path) { ["/event/attach", year].compact.join("/") }

  let(:params) { { dir: } }

  let(:dir) { nil }

  shared_examples :does_not_attach_event do |options|
    let(:errors) { options[:errors] }

    it "renders the expected errors" do
      expect { make_request }.to render_errors(*errors)
    end
  end

  shared_examples :attaches_event do
    it "updates the event location" do
      expect { make_request }
        .to change { event.location.reload.path }
        .from(source_path)
        .to(target_path)
    end

    it "does not render any errors" do
      expect { make_request }.not_to render_errors
    end

    it "renders the expected response" do
      expect { make_request }.to output(<<~TEXT).to_stdout
        #{year} location updated
          from  #{source_path}
          to    #{target_path}
      TEXT
    end
  end

  context "when year is nil" do
    let(:year) { nil }

    include_examples :does_not_attach_event, errors: [
      "Event does not exist"
    ]
  end

  context "when year is valid" do
    let(:year) { 2015 }

    context "and year event has not been initialised" do
      include_examples :does_not_attach_event, errors: [
        "Event does not exist"
      ]
    end

    context "and year event has been initialised" do
      let!(:event) do
        create(:event, :with_location, year:, path: source_path)
      end

      let(:source_path) { temp_path("source").tap(&:mkdir).to_s }

      context "and no dir is specified" do
        let(:dir) { nil }

        include_examples :attaches_event do
          let(:target_path) { temp_dir }
        end
      end

      context "and dir is specified" do
        let(:dir) { temp_path("target").to_s }

        context "and specified dir does not exist" do
          include_examples :does_not_attach_event, errors: [
            "Path does not exist"
          ]
        end

        context "and specified dir exists" do
          before { Dir.mkdir(dir) }

          include_examples :attaches_event do
            let(:target_path) { dir }
          end
        end
      end
    end
  end
end
