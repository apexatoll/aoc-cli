module Matchers
  extend RSpec::Matchers::DSL

  matcher :match_html do |expected|
    def strip_indentation(html)
      html.gsub(/(?=(^|\n))\s*/, "")
    end

    match do |actual|
      expected = strip_indentation(expected)
      actual = strip_indentation(actual)

      expect(actual).to eq(expected)
    end
  end
end
