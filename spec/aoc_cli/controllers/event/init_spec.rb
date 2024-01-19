RSpec.describe "/event/init/:year", :with_temp_dir do
  subject(:make_request) { resolve path, params: }

  let(:path) { ["/event/init", year].compact.join("/") }

  let(:params) { { dir: } }

  let(:dir) { nil }

  shared_examples :does_not_initialise_event do |options|
    let(:errors) { options[:errors] }

    it "does not request the stats" do
      expect { make_request }.not_to request_url(
        "https://adventofcode.com/#{year}"
      )
    end

    it "does not create an Event record" do
      expect { make_request }.not_to create_model(AocCli::Event)
    end

    it "does not create a Stats record" do
      expect { make_request }.not_to create_model(AocCli::Stats)
    end

    it "does not create a Location record" do
      expect { make_request }.not_to create_model(AocCli::Location)
    end

    it "renders the expected errors" do
      expect { make_request }.to render_errors(*errors)
    end
  end

  shared_examples :initialises_event do
    let(:expected_stats) do
      {
        day_1: 2,  day_2: 0,  day_3: 1,  day_4: 0,  day_5: 1,
        day_6: 1,  day_7: 0,  day_8: 2,  day_9: 2,  day_10: 2,
        day_11: 2, day_12: 0, day_13: 2, day_14: 2, day_15: 1,
        day_16: 2, day_17: 2, day_18: 2, day_19: 1, day_20: 0,
        day_21: 1, day_22: 0, day_23: 0, day_24: 0, day_25: 0
      }
    end

    it "requests the stats" do
      expect { make_request }
        .to request_url("https://adventofcode.com/#{year}")
    end

    it "creates an Event" do
      expect { make_request }
        .to create_model(AocCli::Event)
        .with_attributes(year:)
    end

    it "creates a Location" do
      expect { make_request }
        .to create_model(AocCli::Location)
        .with_attributes(path: event_dir)
    end

    it "creates a Stats" do
      expect { make_request }
        .to create_model(AocCli::Stats)
        .with_attributes(**expected_stats)
    end

    it "creates the event directory" do
      expect { make_request }
        .to create_temp_dir(event_dir)
    end

    it "renders the expected output" do
      expect { make_request }.to output(<<~TEXT).to_stdout
        Event initialised
          year  #{year}
          path  #{event_dir}
      TEXT
    end
  end

  context "when in an event directory" do
    include_context :in_event_dir

    include_examples :does_not_initialise_event, errors: [
      "Action can't be performed from Advent of Code directory"
    ]
  end

  context "when in a puzzle directory" do
    include_context :in_puzzle_dir

    include_examples :does_not_initialise_event, errors: [
      "Action can't be performed from Advent of Code directory"
    ]
  end

  context "when not in AoC directory" do
    context "when year is not specified" do
      let(:year) { nil }

      include_examples :does_not_initialise_event, errors: [
        "Year can't be blank"
      ]
    end

    context "when year is before first Advent of Code event" do
      let(:year) { 2010 }

      include_examples :does_not_initialise_event, errors: [
        "Year is before first Advent of Code event (2015)"
      ]
    end

    context "when year is after most recent Advent of Code event" do
      let(:year) { 2040 }

      include_examples :does_not_initialise_event, errors: [
        "Year is in the future"
      ]
    end

    context "when year is valid" do
      let(:year) { 2015 }

      context "and event has already been initialised" do
        before { create(:event, year:) }

        include_examples :does_not_initialise_event, errors: [
          "Event already initialised"
        ]
      end

      context "and event has not already been initialised" do
        around { |spec| VCR.use_cassette("stats-2015") { spec.run } }

        context "and no dir is specified" do
          let(:dir) { nil }

          let(:event_dir) { temp_path(year.to_s).to_s }

          context "and event directory already exists in current directory" do
            before { Dir.mkdir(event_dir) }

            include_examples :does_not_initialise_event, errors: [
              "Event dir already exists"
            ]
          end

          context "and event directory does not exist in current directory" do
            include_examples :initialises_event do
              let(:expected_event_dir) { temp_path(year.to_s).to_s }
            end
          end
        end

        context "and dir is specified" do
          let(:dir) { temp_path("some_dir").to_s }

          let(:event_dir) { Pathname(dir).join(year.to_s).to_s }

          context "and specified dir does not exist" do
            include_examples :does_not_initialise_event, errors: [
              "Dir does not exist"
            ]
          end

          context "and specified dir exists" do
            before { Dir.mkdir(dir) }

            context "and event directory already exists in specified dir" do
              before { Dir.mkdir(event_dir) }

              include_examples :does_not_initialise_event, errors: [
                "Event dir already exists"
              ]
            end

            context "and event directory does not exist in specified dir" do
              include_examples :initialises_event
            end
          end
        end
      end
    end
  end
end
