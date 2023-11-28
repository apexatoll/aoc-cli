require "kangaru"

module AocCli
  extend Kangaru::Initialiser

  config_path File.expand_path("~/.config/aoc.yml")

  config_path "spec/aoc.yml"

  configure do |config|
    config.database.adaptor = :sqlite
    config.database.path = File.expand_path("~/.local/share/aoc/aoc.sqlite3")
    config.database.migration_path = "db/migrate"
  end

  configure env: :test do |config|
    config.database.path = "db/test.sqlite3"
  end

  apply_config!
end
