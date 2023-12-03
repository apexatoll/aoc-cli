module Matchers
  extend RSpec::Matchers::DSL

  matcher :render_errors do |messages|
    def error_bullet = "  \u2022".freeze

    def error_list(messages)
      messages.map { |message| [error_bullet, message].join(" ") }.join("\n")
    end

    def errors_as_list(*messages)
      <<~TEXT
        #{'Error'.red}:
        #{error_list(messages)}
      TEXT
    end

    def error_as_line(message)
      <<~TEXT
        #{'Error'.red}: #{message}
      TEXT
    end

    supports_block_expectations

    match do |action|
      expected = if messages.count > 1
                   errors_as_line(messages.first)
                 else
                   errors_as_list(*messages)
                 end

      expect { action.call }.to output(expected).to_stdout
    end
  end
end
