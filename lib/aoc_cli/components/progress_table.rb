module AocCli
  module Components
    class ProgressTable < Kangaru::Component
      attr_reader :event

      def initialize(event:)
        @event = event
      end

      private

      TITLE    = "Advent of Code: %{year}".freeze
      HEADINGS = %w[Day Progress].freeze
      PROGRESS = "Day %{day}".freeze
      TOTAL    = "Total".freeze

      def title
        format(TITLE, year: event.year)
      end

      def headings
        HEADINGS
      end

      def rows
        [*progress_rows, :separator, total_row]
      end

      def progress_rows
        1.upto(25).map do |day|
          [
            format(PROGRESS, day:),
            event.stats.presenter.progress_icons(day)
          ]
        end
      end

      def total_row
        [TOTAL, event.stats.presenter.total_progress]
      end
    end
  end
end
