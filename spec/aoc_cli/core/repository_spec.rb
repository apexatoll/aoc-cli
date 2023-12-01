RSpec.describe AocCli::Core::Repository do
  before do
    allow(AocCli.config.session).to receive(:token).and_return("token")
  end

  shared_examples :fetches_resource do |options|
    let(:fixture)  { options[:fixture] }
    let(:cassette) { fixture.gsub(/\.\w+$/, "") }

    let(:expected_resource) { File.read("spec/fixtures/#{fixture}") }

    around do |spec|
      VCR.use_cassette(cassette) { spec.run }
    end

    it "returns the expected resource" do
      expect(subject).to eq(expected_resource)
    end
  end

  describe ".get_puzzle" do
    subject(:puzzle) { described_class.get_puzzle(year:, day:) }

    describe "2015" do
      let(:year) { 2015 }
      let(:day)  { 3 }

      include_examples :fetches_resource, fixture: "puzzle-2015-03.md"
    end

    describe "2016" do
      let(:year) { 2016 }
      let(:day)  { 8 }

      include_examples :fetches_resource, fixture: "puzzle-2016-08.md"
    end

    describe "2017" do
      let(:year) { 2017 }
      let(:day)  { 15 }

      include_examples :fetches_resource, fixture: "puzzle-2017-15.md"
    end

    describe "2018" do
      let(:year) { 2018 }
      let(:day)  { 19 }

      include_examples :fetches_resource, fixture: "puzzle-2018-19.md"
    end

    describe "2019" do
      let(:year) { 2019 }
      let(:day)  { 1 }

      include_examples :fetches_resource, fixture: "puzzle-2019-01.md"
    end

    describe "2020" do
      let(:year) { 2020 }
      let(:day)  { 23 }

      include_examples :fetches_resource, fixture: "puzzle-2020-23.md"
    end

    describe "2021" do
      let(:year) { 2021 }
      let(:day)  { 20 }

      include_examples :fetches_resource, fixture: "puzzle-2021-20.md"
    end

    describe "2022" do
      let(:year) { 2022 }
      let(:day)  { 8 }

      include_examples :fetches_resource, fixture: "puzzle-2022-08.md"
    end

    describe "2023" do
      let(:year) { 2023 }
      let(:day)  { 1 }

      include_examples :fetches_resource, fixture: "puzzle-2023-01.md"
    end
  end
end
