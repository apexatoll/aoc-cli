RSpec.describe AocCli::Core::Request do
  subject(:request) { described_class.new(token:) }

  let(:token) { "abcdef123456" }

  let(:client) { instance_double(HTTP::Client) }

  before do
    allow(HTTP).to receive(:headers).and_call_original
    allow(HTTP::Client).to receive(:new).and_return(client)
  end

  shared_examples :sets_up_client do
    let(:expected_cookie) { "session=#{token}" }

    it "sets the authentication cookie" do
      subject
      expect(HTTP).to have_received(:headers).with(Cookie: expected_cookie).once
    end

    it "instantiates an HTTP client" do
      subject
      expect(HTTP::Client).to have_received(:new).once
    end

    it "stores the client" do
      expect(subject.client).to eq(client)
    end
  end

  describe "#initialize" do
    include_examples :sets_up_client
  end

  describe ".build" do
    subject(:request) { described_class.build }

    before do
      allow(AocCli.config.session).to receive(:token).and_return(token)
    end

    context "when session token is not configured" do
      let(:token) { nil }

      it "raises an error" do
        expect { request }.to raise_error("session token not set")
      end
    end

    context "when session token is configured" do
      let(:token) { "123456abcdef" }

      it "does not raises any errors" do
        expect { request }.not_to raise_error
      end

      include_examples :sets_up_client
    end
  end
end
