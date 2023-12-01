RSpec.describe AocCli::Core::Resource do
  subject(:resource) { described_class.new(url:, scope:) }

  let(:url) { "https://example.com/foo/bar" }

  let(:token) { "token" }

  let(:response) do
    <<~HTML
      <!DOCTYPE html>
      <html>
        <head></head>
        <body>
          <main>
            <h1>Title</h1>

            <article>
              <h2>Subtitle</h2>

              <p>Hello world</p>
            </article>
          </main>
        </body>
      </html>
    HTML
  end

  before do
    allow(AocCli.config.session).to receive(:token).and_return(token)

    stub_request(:get, url).to_return(body: response)
  end

  describe "#fetch" do
    subject(:body) { resource.fetch }

    shared_examples :fetches_resource do
      let(:expected_headers) { { Cookie: "session=#{token}" } }

      it "does not raise any errors" do
        expect { body }.not_to raise_error
      end

      it "fetches the resource" do
        body
        assert_requested(:get, url, headers: expected_headers)
      end

      it "returns the expected payload" do
        expect(body).to match_html(expected_payload)
      end
    end

    context "when no scope is specified" do
      let(:scope) { nil }

      include_examples :fetches_resource do
        let(:expected_payload) { response }
      end
    end

    context "when invalid scope is specified" do
      let(:scope) { "foo/bar" }

      include_examples :fetches_resource do
        let(:expected_payload) { "" }
      end
    end

    context "when valid scope is specified" do
      let(:scope) { "html/body/main/article" }

      include_examples :fetches_resource do
        let(:expected_payload) do
          <<~HTML
            <article>
              <h2>Subtitle</h2>

              <p>Hello world</p>
            </article>
          HTML
        end
      end
    end
  end

  describe "#fetch_markdown" do
    subject(:markdown) { resource.fetch_markdown }

    shared_examples :fetches_resource do
      let(:expected_headers) { { Cookie: "session=#{token}" } }

      it "does not raise any errors" do
        expect { markdown }.not_to raise_error
      end

      it "fetches the resource" do
        markdown
        assert_requested(:get, url, headers: expected_headers)
      end

      it "returns the expected markdown" do
        expect(markdown).to eq(expected_markdown)
      end
    end

    context "when no scope is specified" do
      let(:scope) { nil }

      include_examples :fetches_resource do
        let(:expected_markdown) do
          <<~MD
            # Title

            ## Subtitle

            Hello world
          MD
        end
      end
    end

    context "when invalid scope is specified" do
      let(:scope) { "foo/bar" }

      include_examples :fetches_resource do
        let(:expected_markdown) { "" }
      end
    end

    context "when valid scope is specified" do
      let(:scope) { "html/body/main/article" }

      include_examples :fetches_resource do
        let(:expected_markdown) do
          <<~HTML
            ## Subtitle

            Hello world
          HTML
        end
      end
    end
  end
end
