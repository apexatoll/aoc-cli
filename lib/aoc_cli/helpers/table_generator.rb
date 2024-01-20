module AocCli
  module Helpers
    class TableGenerator
      include Kangaru::Validatable

      attr_reader :rows, :gap, :indent

      validates :rows, collection_type: { all: Array }

      def initialize(rows:, gap: 2, indent: 0)
        @rows = rows
        @gap = gap
        @indent = indent
      end

      # TODO: Use validates via method for checking row length once supported.
      def validate
        super
        validate_rows_are_same_length! if errors.empty?
      end

      # TODO: Remove once validate! merged upstream.
      def validate!
        validate

        raise errors.map(&:full_message).join("\n") unless errors.empty?
      end

      def generate!
        validate!

        rows.map do |row|
          [
            space(indent),
            format_row!(row),
            "\n"
          ].join
        end.join
      end

      private

      def column_widths
        @column_widths ||= rows.transpose.map do |column|
          column.map(&:length).max + gap
        end
      end

      def space(count)
        " " * count
      end

      def format_row!(row)
        row.zip(column_widths).map do |string, column_width|
          string + space((column_width || raise) - string.length)
        end.join
      end

      def validate_rows_are_same_length!
        return if rows.all? { |row| row.length == rows[0].length }

        errors << Kangaru::Validation::Error.new(
          attribute: :rows, message: "must all be the same length"
        )
      end
    end
  end
end
