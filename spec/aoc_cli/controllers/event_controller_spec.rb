RSpec.describe AocCli::EventController, :with_temp_dir do
  around { |spec| Dir.chdir(temp_dir) { spec.run } }

  describe "/event/init/:year" do
    subject(:make_request) { resolve path, params: }

    let(:path) { ["/event/init", year].compact.join("/") }

    let(:params) { { dir: }.compact }

    let(:dir) { nil }

    def event_dir
      return Pathname.pwd.join(year.to_s).to_s if dir.nil?

      Pathname(dir).join(year.to_s).to_s
    end

    shared_examples :does_not_initialise_event do |options|
      let(:errors) { options[:errors] }

      it "does not create an Event record" do
        expect { make_request }.not_to create_model(AocCli::Event)
      end

      it "does not create a Stats record" do
        expect { make_request }.not_to create_model(AocCli::Stats)
      end

      it "does not create a Location record" do
        expect { make_request }.not_to create_model(AocCli::Location)
      end

      it "does not create the event dir" do
        expect { make_request }.not_to create_temp_dir(event_dir)
      end

      it "renders the errors" do
        expect { make_request }.to render_errors(*errors)
      end
    end

    shared_examples :initialises_new_event do
      let(:event) { AocCli::Event.last }

      it "creates an Event record" do
        expect { make_request }.to create_model(AocCli::Event)
      end

      it "creates a Stats record" do
        expect { make_request }.to create_model(AocCli::Stats)
      end

      it "creates a Location record" do
        expect { make_request }.to create_model(AocCli::Location)
      end

      it "sets the Event attributes" do
        make_request
        expect(event).to have_attributes(year:)
      end

      it "sets the Stats attributes" do
        make_request
        expect(event.stats).to have_attributes(day_1: 2)
      end

      it "sets the Location attributes" do
        make_request
        expect(event.location).to have_attributes(path: event_dir)
      end

      it "creates the event directory" do
        expect { make_request }.to create_temp_dir(event_dir)
      end

      it "does not render errors" do
        expect { make_request }.not_to render_errors
      end

      it "renders the default template" do
        expect { make_request }.to render_template(:init)
      end
    end

    shared_examples :initialises_existing_event do
      let(:event) { AocCli::Event.last }

      let(:initial_event_dir) { File.join(initial_dir, year.to_s) }

      around { |spec| use_stats_cassette(year:, tag:) { spec.run } }

      shared_examples :updates_event do
        it "does not create an Event record" do
          expect { make_request }.not_to create_model(AocCli::Event)
        end

        it "does not create a Stats record" do
          expect { make_request }.not_to create_model(AocCli::Stats)
        end

        it "does not create a Location record" do
          expect { make_request }.not_to create_model(AocCli::Location)
        end

        it "does not update the Event attributes" do
          expect { make_request }.not_to change { event.reload.values }
        end

        it "updates the Location path attribute" do
          expect { make_request }
            .to change { event.location.reload.path }
            .from(initial_event_dir)
            .to(event_dir)
        end

        it "creates the new event directory" do
          expect { make_request }.to create_temp_dir(event_dir)
        end
      end

      context "when stats have not changed since first initialisation" do
        let(:tag) { :duplicate }

        include_examples :updates_event

        it "does not update the Stats attributes" do
          expect { make_request }.not_to change { event.stats.reload.values }
        end
      end

      context "when stats have changed since first initialisation" do
        let(:tag) { :less_complete }

        include_examples :updates_event

        it "updates the Stats attributes" do
          expect { make_request }
            .to change { event.stats.reload.day_1 }
            .from(1)
            .to(2)
        end
      end
    end

    shared_examples :initialises_event do
      context "and event has not already been initialised" do
        include_examples :initialises_new_event
      end

      context "and event has already been initialised" do
        before { resolve path, params: { dir: initial_dir } }

        context "and event was initialised in specified dir" do
          let(:initial_dir) { dir }

          include_examples :does_not_initialise_event, errors: [
            "Year dir already exists"
          ]
        end

        context "and event was not initialised in specified dir" do
          let(:initial_dir) { temp_path("initial").tap(&:mkdir).to_s }

          include_examples :initialises_existing_event
        end
      end
    end

    context "when no event year is specified" do
      let(:year) { nil }

      include_examples :does_not_initialise_event, errors: [
        "Year can't be blank"
      ]
    end

    context "when year is before first AoC event" do
      let(:year) { 2014 }

      include_examples :does_not_initialise_event, errors: [
        "Year is before first Advent of Code event (2015)"
      ]
    end

    context "when year is after most recent AoC event" do
      let(:year) { 2048 }

      include_examples :does_not_initialise_event, errors: [
        "Year is in the future"
      ]
    end

    context "when valid event year is specified" do
      let(:year) { 2023 }

      around { |spec| use_stats_cassette(year:) { spec.run } }

      context "and non-existent dir is specified" do
        let(:dir) { temp_path("does-not-exist").to_s }

        include_examples :does_not_initialise_event, errors: [
          "Dir does not exist"
        ]
      end

      context "and no dir is specified" do
        let(:dir) { nil }

        include_examples :initialises_event
      end

      context "and valid dir is specified" do
        let(:dir) { temp_path("subdir").tap(&:mkdir).to_s }

        include_examples :initialises_event
      end
    end
  end
end
