RSpec.describe AocCli::Core::Repository do
  describe ".get_stats" do
    subject(:stats) { described_class.get_stats(year:) }

    around { |spec| use_stats_cassette(year:) { spec.run } }

    shared_examples :fetches_stats do
      it "makes the expected GET request" do
        stats
        assert_requested(:get, "https://adventofcode.com/#{year}")
      end

      it "returns the expected stats" do
        expect(stats).to eq(expected_stats)
      end
    end

    context "when the event has fully completed" do
      let(:year) { 2015 }

      let(:expected_stats) do
        {
          day_1: 2,  day_2: 0,  day_3: 1,  day_4: 0,  day_5: 1,
          day_6: 1,  day_7: 0,  day_8: 2,  day_9: 2,  day_10: 2,
          day_11: 2, day_12: 0, day_13: 2, day_14: 2, day_15: 1,
          day_16: 2, day_17: 2, day_18: 2, day_19: 1, day_20: 0,
          day_21: 1, day_22: 0, day_23: 0, day_24: 0, day_25: 0
        }
      end

      include_examples :fetches_stats
    end

    context "when the event is ongoing" do
      let(:year) { 2023 }

      let(:expected_stats) do
        {
          day_1: 2,  day_2: 0,  day_3: 0,  day_4: 0,  day_5: 0,
          day_6: 0,  day_7: 0,  day_8: 0,  day_9: 0,  day_10: 0,
          day_11: 0, day_12: 0, day_13: 0, day_14: 0, day_15: 0
        }
      end

      include_examples :fetches_stats
    end
  end

  describe ".get_puzzle" do
    subject(:puzzle) { described_class.get_puzzle(year:, day:) }

    around { |spec| use_puzzle_cassette(year:, day:) { spec.run } }

    shared_examples :gets_puzzle do
      it "makes the expected GET request" do
        puzzle
        assert_requested(:get, "#{described_class::HOST}/#{year}/day/#{day}")
      end

      it "returns the expected resource" do
        expect(puzzle).to eq(puzzle_fixture(year:, day:))
      end
    end

    describe "2015" do
      let(:year) { 2015 }
      let(:day)  { 3 }

      include_examples :gets_puzzle
    end

    describe "2016" do
      let(:year) { 2016 }
      let(:day)  { 8 }

      include_examples :gets_puzzle
    end

    describe "2017" do
      let(:year) { 2017 }
      let(:day)  { 15 }

      include_examples :gets_puzzle
    end

    describe "2018" do
      let(:year) { 2018 }
      let(:day)  { 19 }

      include_examples :gets_puzzle
    end

    describe "2019" do
      let(:year) { 2019 }
      let(:day)  { 1 }

      include_examples :gets_puzzle
    end

    describe "2020" do
      let(:year) { 2020 }
      let(:day)  { 23 }

      include_examples :gets_puzzle
    end

    describe "2021" do
      let(:year) { 2021 }
      let(:day)  { 20 }

      include_examples :gets_puzzle
    end

    describe "2022" do
      let(:year) { 2022 }
      let(:day)  { 8 }

      include_examples :gets_puzzle
    end

    describe "2023" do
      let(:year) { 2023 }
      let(:day)  { 1 }

      include_examples :gets_puzzle
    end
  end

  describe ".get_input" do
    subject(:input) { described_class.get_input(year:, day:) }

    around { |spec| use_input_cassette(year:, day:) { spec.run } }

    shared_examples :gets_input do
      it "makes the expected GET request" do
        input

        assert_requested(
          :get, "#{described_class::HOST}/#{year}/day/#{day}/input"
        )
      end

      it "returns the expected resource" do
        expect(input).to eq(input_fixture(year:, day:))
      end
    end

    describe "2015" do
      let(:year) { 2015 }
      let(:day)  { 3 }

      include_examples :gets_input
    end

    describe "2016" do
      let(:year) { 2016 }
      let(:day)  { 8 }

      include_examples :gets_input
    end

    describe "2017" do
      let(:year) { 2017 }
      let(:day)  { 15 }

      include_examples :gets_input
    end

    describe "2018" do
      let(:year) { 2018 }
      let(:day)  { 19 }

      include_examples :gets_input
    end

    describe "2019" do
      let(:year) { 2019 }
      let(:day)  { 1 }

      include_examples :gets_input
    end

    describe "2020" do
      let(:year) { 2020 }
      let(:day)  { 23 }

      include_examples :gets_input
    end

    describe "2021" do
      let(:year) { 2021 }
      let(:day)  { 20 }

      include_examples :gets_input
    end

    describe "2022" do
      let(:year) { 2022 }
      let(:day)  { 8 }

      include_examples :gets_input
    end

    describe "2023" do
      let(:year) { 2023 }
      let(:day) { 1 }

      include_examples :gets_input
    end
  end

  describe ".post_solution" do
    subject(:response) do
      described_class.post_solution(year:, day:, level:, answer:)
    end

    let(:year) { 2016 }

    let(:day) { 2 }

    around do |spec|
      use_solution_cassette(year:, day:, level:, tag:) { spec.run }
    end

    shared_examples :makes_expected_post_request do
      let(:data) { { level:, answer: } }

      let(:body) { URI.encode_www_form(data) }

      let(:url) { "#{described_class::HOST}/#{year}/day/#{day}/answer" }

      it "makes the expected POST request" do
        response
        assert_requested(:post, url, body:)
      end
    end

    shared_examples :returns_response_hash do |attributes|
      it "returns the expected parsed response hash" do
        expect(response).to eq(**attributes)
      end
    end

    context "when on part one of the puzzle" do
      context "and level is specified correctly as one" do
        let(:level) { 1 }

        context "and vastly incorrect answer is given" do
          let(:answer) { "hello world" }
          let(:tag)    { :incorrect }

          include_examples :makes_expected_post_request

          include_examples :returns_response_hash,
                           status: :incorrect, wait_time: 1
        end

        context "and answer is too low" do
          let(:answer) { 99_331 }
          let(:tag)    { :incorrect_too_low }

          include_examples :makes_expected_post_request

          include_examples :returns_response_hash,
                           status: :incorrect, hint: :too_low, wait_time: 1
        end

        context "and answer is too high" do
          let(:answer) { 99_333 }
          let(:tag)    { :incorrect_too_high }

          include_examples :makes_expected_post_request

          include_examples :returns_response_hash,
                           status: :incorrect, hint: :too_high, wait_time: 5
        end

        context "and answering is rate-limited" do
          let(:answer) { 99_332 }
          let(:tag)    { :rate_limited }

          include_examples :makes_expected_post_request

          include_examples :returns_response_hash,
                           status: :rate_limited, wait_time: 4
        end

        context "and answer is correct" do
          let(:answer) { 99_332 }
          let(:tag)    { :correct }

          include_examples :makes_expected_post_request
          include_examples :returns_response_hash, status: :correct
        end
      end

      context "and level is specified incorrectly as two" do
        let(:level)  { 2 }
        let(:answer) { 99_332 }
        let(:tag)    { :wrong_level }

        include_examples :makes_expected_post_request
        include_examples :returns_response_hash, status: :wrong_level
      end
    end

    context "when on part two of the puzzle" do
      context "and level is specified incorrectly as one" do
        let(:level)  { 1 }
        let(:answer) { "DD483" }
        let(:tag)    { :wrong_level }

        include_examples :makes_expected_post_request
        include_examples :returns_response_hash, status: :wrong_level
      end

      context "and level is specified correctly as two" do
        let(:level) { 2 }

        context "and incorrect answer is given" do
          let(:answer) { "hello world" }
          let(:tag)    { :incorrect }

          include_examples :makes_expected_post_request

          include_examples :returns_response_hash,
                           status: :incorrect, wait_time: 1
        end

        context "and answering is rate-limited" do
          let(:answer) { "DD483" }
          let(:tag)    { :rate_limited }

          include_examples :makes_expected_post_request

          include_examples :returns_response_hash,
                           status: :rate_limited, wait_time: 4
        end

        context "and answer is correct" do
          let(:answer) { "DD483" }
          let(:tag)    { :correct }

          include_examples :makes_expected_post_request
          include_examples :returns_response_hash, status: :correct
        end
      end
    end
  end
end
