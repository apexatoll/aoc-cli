module Matchers
  extend RSpec::Matchers::DSL

  matcher :request_url do |url|
    supports_block_expectations

    match do |action|
      @method ||= :get

      assert_not_requested(@method, url)
      action.call
      assert_requested(@method, url)

      true
    end

    chain :via do |method|
      @method = method
    end
  end
end
