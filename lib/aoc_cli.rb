require "kangaru"

module AocCli
  extend Kangaru::Initialiser

  config_path File.expand_path("~/.config/aoc.yml")

  config_path "spec/aoc.yml"

  apply_config!
end
