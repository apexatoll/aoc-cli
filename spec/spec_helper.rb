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

  config.include CassetteHelpers
  config.include FixtureHelpers
  config.include PathHelpers
  config.include RequestHelpers

  def spec_dir
    Pathname(File.expand_path(__dir__))
  end

  def formatted_day(day)
    day&.to_s&.rjust(2, "0")
  end

  # TODO: Controller class should not be cached by Kangaru. This raises an
  # error when more than one controller is requested as it is cached.
  config.before(type: :request) do
    router = Kangaru.application.router

    if router.instance_variable_defined?(:@controller_class)
      router.remove_instance_variable(:@controller_class)
    end
  end
end
