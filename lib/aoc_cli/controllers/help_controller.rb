module AocCli
  class HelpController < ApplicationController
    def default
      Components::HelpComponent.new.render
    end

    alias help default
  end
end
