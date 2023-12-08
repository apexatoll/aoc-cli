module AocCli
  module Core
    class Repository
      HOST = "https://adventofcode.com".freeze

      RESOURCES = {
        stats: {
          url: "%{host}/%{year}",
          scope: "html/body/main/pre",
          method: :get
        },

        puzzle: {
          url: "%{host}/%{year}/day/%{day}",
          scope: "html/body/main/article",
          method: :get
        },

        input: {
          url: "%{host}/%{year}/day/%{day}/input",
          method: :get
        },

        solution: {
          url: "%{host}/%{year}/day/%{day}/answer",
          scope: "html/body/main/article",
          method: :post,
          params: %i[level answer]
        }
      }.freeze

      class << self
        def get_stats(year:)
          html = build_resource(:stats, year:).fetch

          StatsParser.new(html).to_h
        end

        def get_puzzle(year:, day:)
          build_resource(:puzzle, year:, day:).fetch_markdown
        end

        def get_input(year:, day:)
          build_resource(:input, year:, day:).fetch
        end

        def post_solution(year:, day:, level:, answer:)
          response = build_resource(
            :solution, year:, day:, level:, answer:
          ).fetch_markdown

          AttemptParser.new(response).to_h
        end

        private

        def build_resource(type, **params)
          attributes = RESOURCES[type]

          Resource.new(
            url: format_url(attributes[:url], **params),
            scope: attributes[:scope],
            method: attributes[:method],
            params: params.slice(*attributes[:params])
          )
        end

        def format_url(template, **params)
          format(template, host: HOST, **params)
        end
      end
    end
  end
end
