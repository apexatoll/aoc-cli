module AocCli
  module Core
    # Scope filters the response with the given xpath which ensures that only
    # desired content is extracted from the (usually) HTML response. The whole
    # response is considered the resource payload if no scope is specified.
    class Resource
      attr_reader :url, :scope

      def initialize(url:, scope: nil)
        @url = url
        @scope = scope
      end

      def fetch
        return response if scope.nil?

        Nokogiri.HTML5(response).xpath(scope).to_html
      end

      # Bypess ignores unknown tags and tries to convert their nested content.
      # The parser adds an extra newline to the end which is removed with chomp.
      def fetch_markdown
        ReverseMarkdown.convert(fetch, unknown_tags: :bypass).chomp
      end

      private

      def response
        @response ||= Request.build.get(url).to_s
      end
    end
  end
end
