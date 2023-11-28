module AocCli
  module Core
    class Request
      attr_reader :client

      def initialize(token:)
        @client = setup_client!(token)
      end

      def self.build
        token = AocCli.config.session.token

        raise "session token not set" if token.nil?

        new(token:)
      end

      private

      def setup_client!(token)
        cookie = "session=#{token}"

        HTTP.headers(Cookie: cookie)
      end
    end
  end
end
