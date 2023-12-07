RSpec.describe AocCli::Core::Repository do
  before do
    allow(AocCli.config.session).to receive(:token).and_return("token")
  end

  def resource_to_cassette(resource)
    resource.gsub(/\.\w+$/, "")
  end

  def path_to_url(path)
    File.join(described_class::HOST, path)
  end

  shared_examples :gets_resource do |options|
    let(:path)     { options[:path] }
    let(:resource) { options[:resource] }
    let(:cassette) { resource_to_cassette(resource) }

    around do |spec|
      VCR.use_cassette(cassette) { spec.run }
    end

    it "makes the expected GET request" do
      subject
      assert_requested(:get, path_to_url(path))
    end

    it "returns the expected resource" do
      expect(subject).to eq(fixture(resource))
    end
  end

  describe ".get_stats" do
    subject(:stats) { described_class.get_stats(year:) }

    let(:year) { 2015 }

    let(:expected_stats) do
      {
        day_1: 2,
        day_2: 0,
        day_3: 1,
        day_4: 0,
        day_5: 1,
        day_6: 1,
        day_7: 0,
        day_8: 2,
        day_9: 2,
        day_10: 2,
        day_11: 2,
        day_12: 0,
        day_13: 2,
        day_14: 2,
        day_15: 1,
        day_16: 2,
        day_17: 2,
        day_18: 2,
        day_19: 1,
        day_20: 0,
        day_21: 1,
        day_22: 0,
        day_23: 0,
        day_24: 0,
        day_25: 0
      }
    end

    around do |spec|
      VCR.use_cassette("stats-2015") { spec.run }
    end

    it "makes the expected GET request" do
      stats
      assert_requested(:get, "https://adventofcode.com/2015")
    end

    it "returns the expected stats" do
      expect(stats).to eq(expected_stats)
    end
  end

  describe ".get_puzzle" do
    subject(:puzzle) { described_class.get_puzzle(year:, day:) }

    describe "2015" do
      let(:year) { 2015 }
      let(:day)  { 3 }

      include_examples :gets_resource,
                       path: "2015/day/3",
                       resource: "puzzle-2015-03.md"
    end

    describe "2016" do
      let(:year) { 2016 }
      let(:day)  { 8 }

      include_examples :gets_resource,
                       path: "2016/day/8",
                       resource: "puzzle-2016-08.md"
    end

    describe "2017" do
      let(:year) { 2017 }
      let(:day)  { 15 }

      include_examples :gets_resource,
                       path: "2017/day/15",
                       resource: "puzzle-2017-15.md"
    end

    describe "2018" do
      let(:year) { 2018 }
      let(:day)  { 19 }

      include_examples :gets_resource,
                       path: "2018/day/19",
                       resource: "puzzle-2018-19.md"
    end

    describe "2019" do
      let(:year) { 2019 }
      let(:day)  { 1 }

      include_examples :gets_resource,
                       path: "2019/day/1",
                       resource: "puzzle-2019-01.md"
    end

    describe "2020" do
      let(:year) { 2020 }
      let(:day)  { 23 }

      include_examples :gets_resource,
                       path: "2020/day/23",
                       resource: "puzzle-2020-23.md"
    end

    describe "2021" do
      let(:year) { 2021 }
      let(:day)  { 20 }

      include_examples :gets_resource,
                       path: "2021/day/20",
                       resource: "puzzle-2021-20.md"
    end

    describe "2022" do
      let(:year) { 2022 }
      let(:day)  { 8 }

      include_examples :gets_resource,
                       path: "2022/day/8",
                       resource: "puzzle-2022-08.md"
    end

    describe "2023" do
      let(:year) { 2023 }
      let(:day)  { 1 }

      include_examples :gets_resource,
                       path: "2023/day/1",
                       resource: "puzzle-2023-01.md"
    end
  end

  describe ".get_input" do
    subject(:input) { described_class.get_input(year:, day:) }

    describe "2015" do
      let(:year) { 2015 }
      let(:day)  { 3 }

      include_examples :gets_resource,
                       path: "2015/day/3/input",
                       resource: "input-2015-03"
    end

    describe "2016" do
      let(:year) { 2016 }
      let(:day)  { 8 }

      include_examples :gets_resource,
                       path: "2016/day/8/input",
                       resource: "input-2016-08"
    end

    describe "2017" do
      let(:year) { 2017 }
      let(:day)  { 15 }

      include_examples :gets_resource,
                       path: "2017/day/15/input",
                       resource: "input-2017-15"
    end

    describe "2018" do
      let(:year) { 2018 }
      let(:day)  { 19 }

      include_examples :gets_resource,
                       path: "2018/day/19/input",
                       resource: "input-2018-19"
    end

    describe "2019" do
      let(:year) { 2019 }
      let(:day)  { 1 }

      include_examples :gets_resource,
                       path: "2019/day/1/input",
                       resource: "input-2019-01"
    end

    describe "2020" do
      let(:year) { 2020 }
      let(:day)  { 23 }

      include_examples :gets_resource,
                       path: "2020/day/23/input",
                       resource: "input-2020-23"
    end

    describe "2021" do
      let(:year) { 2021 }
      let(:day)  { 20 }

      include_examples :gets_resource,
                       path: "2021/day/20/input",
                       resource: "input-2021-20"
    end

    describe "2022" do
      let(:year) { 2022 }
      let(:day)  { 8 }

      include_examples :gets_resource,
                       path: "2022/day/8/input",
                       resource: "input-2022-08"
    end

    describe "2023" do
      let(:year) { 2023 }
      let(:day) { 1 }

      include_examples :gets_resource,
                       path: "2023/day/1/input",
                       resource: "input-2023-01"
    end
  end
end
