module ConcernHelpers
  def controller
    controller_class.new
  end

  def controller_class
    Class.new(AocCli::ApplicationController) do
      def initialize; end # rubocop:disable Style/RedundantInitialize
    end
  end
end
