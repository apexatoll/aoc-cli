require "fileutils"
require "forwardable"
require "http"
require "kangaru"
require "nokogiri"
require "reverse_markdown"
require "terminal-table"

module AocCli
  extend Kangaru::Initialiser

  config_path File.expand_path("~/.config/aoc_cli/config.yml")

  config_path "spec/aoc.yml", env: :test

  configure do |config|
    config.database.adaptor = :sqlite
    config.database.path = File.expand_path("~/.local/share/aoc/aoc.sqlite3")
    config.database.migration_path = "db/migrate"

    config.request.default_controller = HelpController
  end

  configure env: :test do |config|
    config.database.path = "db/test.sqlite3"
  end

  apply_config!

  Sequel::Model.plugin(:polymorphic)
  Sequel::Model.plugin(:enum)

  Terminal::Table::Style.defaults = {
    border: :unicode,
    alignment: :center
  }
end
