module AocCli
  module Core
    class Request
      attr_reader :client

      def initialize(token:)
        @client = setup_client!(token)
      end

      private

      def setup_client!(token)
        cookie = "session=#{token}"

        HTTP.headers(Cookie: cookie)
      end
    end
  end
end
