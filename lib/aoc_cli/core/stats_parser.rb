module AocCli
  module Core
    # Calculates a User's year progress by parsing the CSS classes that are
    # applied to each calendar link in the calendar view.
    class StatsParser
      DAY_CLASS_PREFIX = "calendar-day".freeze
      ONE_STAR_CLASS   = "calendar-complete".freeze
      TWO_STARS_CLASS  = "calendar-verycomplete".freeze

      attr_reader :calendar_html

      def initialize(calendar_html)
        @calendar_html = calendar_html
      end

      def to_h
        calendar_link_classes.to_h do |classes|
          day = classes[0].delete_prefix(DAY_CLASS_PREFIX)
          n_stars = count_stars(classes)

          [:"day_#{day}", n_stars]
        end
      end

      private

      def calendar_link_classes
        calendar_links.map(&:classes)
      end

      def calendar_links
        Nokogiri.HTML5(calendar_html).xpath("//a")
      end

      def count_stars(classes)
        return 2 if classes.include?(TWO_STARS_CLASS)
        return 1 if classes.include?(ONE_STAR_CLASS)

        0
      end
    end
  end
end
