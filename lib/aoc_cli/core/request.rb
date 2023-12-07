module AocCli
  module Core
    class Request
      extend Forwardable

      attr_reader :client

      def_delegators :client, :get

      def initialize(token:)
        @client = setup_client!(token)
      end

      def self.build
        token = AocCli.config.session.token

        raise "session token not set" if token.nil?

        new(token:)
      end

      class << self
        extend Forwardable

        def_delegators :build, :get
      end

      private

      def setup_client!(token)
        cookie = "session=#{token}"

        HTTP.headers(Cookie: cookie)
      end
    end
  end
end
