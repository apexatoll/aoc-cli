RSpec.describe AocCli::Core::Request do
  subject(:request) { described_class.new(token:) }

  let(:token) { "abcdef123456" }

  let(:client) { instance_double(HTTP::Client) }

  before do
    allow(HTTP).to receive(:headers).and_call_original
    allow(HTTP::Client).to receive(:new).and_return(client)
  end

  describe "#initialize" do
    let(:expected_cookie) { "session=#{token}" }

    it "sets the authentication cookie" do
      request
      expect(HTTP).to have_received(:headers).with(Cookie: expected_cookie).once
    end

    it "instantiates an HTTP client" do
      request
      expect(HTTP::Client).to have_received(:new).once
    end

    it "stores the client" do
      expect(request.client).to eq(client)
    end
  end
end
