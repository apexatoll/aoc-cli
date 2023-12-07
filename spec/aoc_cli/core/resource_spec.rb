RSpec.describe AocCli::Core::Resource do
  subject(:resource) { described_class.new(url:, scope:, method:, params:) }

  let(:url) { "https://example.com/foo/bar" }

  let(:params) { {} }

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
    stub_request(:post, url).to_return(body: response)
  end

  describe "#fetch" do
    subject(:body) { resource.fetch }

    shared_examples :fetches_resource do
      let(:expected_headers) { { Cookie: "session=#{token}" } }

      context "when an invalid method is set" do
        let(:method) { :foobar }

        it "raises an error" do
          expect { body }.to raise_error("invalid HTTP method")
        end
      end

      context "when method is set to :get" do
        let(:method) { :get }

        it "does not raise any errors" do
          expect { body }.not_to raise_error
        end

        it "fetches the resource via HTTP :get" do
          body
          assert_requested(:get, url, headers: expected_headers)
        end

        it "returns the expected payload" do
          expect(body).to match_html(expected_payload)
        end
      end

      context "when method is set to :post" do
        let(:method) { :post }

        let(:params) { { foo: "foo", bar: "bar" } }

        it "does not raise any errors" do
          expect { body }.not_to raise_error
        end

        it "fetches the resource via HTTP :post" do
          body
          assert_requested(:post, url, headers: expected_headers, body: params)
        end

        it "returns the expected payload" do
          expect(body).to match_html(expected_payload)
        end
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

      context "when an invalid method is set" do
        let(:method) { :foobar }

        it "raises an error" do
          expect { markdown }.to raise_error("invalid HTTP method")
        end
      end

      context "when method is set to :get" do
        let(:method) { :get }

        it "does not raise any errors" do
          expect { markdown }.not_to raise_error
        end

        it "fetches the resource via HTTP :get" do
          markdown
          assert_requested(:get, url, headers: expected_headers)
        end

        it "returns the expected markdown" do
          expect(markdown).to eq(expected_markdown)
        end
      end

      context "when method is set to :post" do
        let(:method) { :post }

        let(:params) { { foo: "foo", bar: "bar" } }

        it "does not raise any errors" do
          expect { markdown }.not_to raise_error
        end

        it "fetches the resource via HTTP :post" do
          markdown
          assert_requested(:post, url, headers: expected_headers, body: params)
        end

        it "returns the expected markdown" do
          expect(markdown).to eq(expected_markdown)
        end
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
