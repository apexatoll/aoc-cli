module AocCli
  module Configurators
    class SessionConfigurator < Kangaru::Configurator
      attr_accessor :token
    end
  end
end
