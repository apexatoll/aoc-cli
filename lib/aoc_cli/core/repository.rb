module AocCli
  module Core
    class Repository
      class << self
        HOST = "https://adventofcode.com".freeze

        RESOURCES = {}.freeze

        private

        def build_resource(type, **params)
          attributes = RESOURCES[type]

          Resource.new(
            url: format_url(attributes[:url], **params),
            scope: attributes[:scope]
          )
        end

        def format_url(template, **params)
          format(template, host: HOST, **params)
        end
      end
    end
  end
end
