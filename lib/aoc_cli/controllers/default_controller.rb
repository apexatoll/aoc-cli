module AocCli
  class DefaultController < ApplicationController
    def default
      Components::DocsComponent.new.render
    end

    alias help default
  end
end
