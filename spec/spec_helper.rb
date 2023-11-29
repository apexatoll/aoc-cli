require "aoc_cli"

RSpec.configure do |config|
  Kernel.srand(config.seed)

  Dir[File.join(__dir__, "support/**/*.rb")].each { |file| require file }

  config.disable_monkey_patching!

  config.mock_with(:rspec) { |mocks| mocks.verify_partial_doubles = true }

  config.order = :random

  config.default_formatter = :doc if config.files_to_run.one?
end
