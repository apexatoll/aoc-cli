module AocCli
  module Configurators
    class AuthConfigurator < Kangaru::Configurator
      attr_accessor :session
    end
  end
end
