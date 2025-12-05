module AocCli
  module Core
    class Request
      attr_reader :client, :ssl_context

      def initialize(token:)
        @client = setup_client!(token)
        @ssl_context = setup_ssl_context!
      end

      def self.build
        token = AocCli.config.session.token

        raise "session token not set" if token.nil?

        new(token:)
      end

      def get(url)
        client.get(url, **default_options)
      end

      def post(url, **options)
        client.post(url, **default_options.merge(options))
      end

      class << self
        extend Forwardable

        def_delegators :build, :get, :post
      end

      private

      def setup_client!(token)
        cookie = "session=#{token}"

        HTTP.headers(Cookie: cookie)
      end

      def setup_ssl_context!
        OpenSSL::SSL::SSLContext.new do |context|
          context.cert_store = OpenSSL::X509::Store.new.tap(&:set_default_paths)
          context.cert_store.flags = 0
        end
      end

      def default_options
        { ssl_context: }
      end
    end
  end
end
