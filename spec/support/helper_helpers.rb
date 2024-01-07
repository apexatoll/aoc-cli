module HelperHelpers
  def helper
    helper_class.new
  end

  def helper_class
    Class.new(AocCli::ApplicationController) do
      def initialize; end # rubocop:disable Style/RedundantInitialize
    end
  end
end
