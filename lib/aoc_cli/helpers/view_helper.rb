module AocCli
  module Helpers
    module ViewHelper
      def main_header
        heading("aoc-cli::<#{VERSION}>")
      end

      def heading(text)
        text.to_s.bold.cyan
      end

      def table_for(*rows, gap: 2, indent: 0)
        TableGenerator.new(rows:, gap:, indent:).generate!
      end

      def wrap_text(text, width: 80)
        text.gsub(
          /(.{1,#{width}})(?:[^\S\n]+\n?|\n*\Z|\n)|\n/, "\\1\n"
        )
      end
    end
  end
end
