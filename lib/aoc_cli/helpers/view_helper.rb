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

      def wrap_text(text, width: 80, indent: 0)
        raise "indent must be less than width" unless indent < width

        text.gsub(
          # Match the longest string (up to the indented width) thats followed
          # by a non-word char or any combination of newlines.
          /(.{1,#{width - indent}})(?:[^\S\n]+\n?|\n*\Z|\n)|\n/,
          # Surround string fragment with indent and newline.
          "#{' ' * indent}\\1\n"
        )
      end
    end
  end
end
