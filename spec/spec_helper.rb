require "aoc_cli"
require "factory_bot"
require "webmock/rspec"
require "vcr"

RSpec.configure do |config|
  Kernel.srand(config.seed)

  Dir[File.join(__dir__, "support/**/*.rb")].each { |file| require file }

  config.disable_monkey_patching!

  config.mock_with(:rspec) { |mocks| mocks.verify_partial_doubles = true }

  config.order = :random

  config.default_formatter = :doc if config.files_to_run.one?

  config.before(:suite) do
    FactoryBot.find_definitions

    FactoryBot.define { to_create(&:save) }
  end

  VCR.configure do |vcr|
    vcr.hook_into :webmock
    vcr.cassette_library_dir = "spec/fixtures"
  end

  config.include FactoryBot::Syntax::Methods

  config.include Matchers

  def fixture(file)
    File.read(File.join("spec/fixtures", file))
  end
end
