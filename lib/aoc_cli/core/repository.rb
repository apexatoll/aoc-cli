module AocCli
  module Core
    class Repository
      class << self
        HOST = "https://adventofcode.com".freeze

        RESOURCES = {
          puzzle: {
            url: "%{host}/%{year}/day/%{day}",
            scope: "html/body/main/article"
          }
        }.freeze

        def get_puzzle(year:, day:)
          build_resource(:puzzle, year:, day:).fetch_markdown
        end

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
