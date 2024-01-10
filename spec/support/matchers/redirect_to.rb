module Matchers
  extend RSpec::Matchers::DSL

  matcher :redirect_to do |path|
    supports_block_expectations

    match do |action|
      params = @params || {}

      allow(Kangaru.application!.router)
        .to receive(:resolve)
        .and_call_original

      expect(Kangaru.application!.router)
        .not_to have_received(:resolve)
        .with(an_object_having_attributes(path:, params:))

      action.call

      expect(Kangaru.application!.router)
        .to have_received(:resolve)
        .with(an_object_having_attributes(path:, params:))
        .once
    end

    chain :with_params do |params|
      @params = params
    end
  end
end
