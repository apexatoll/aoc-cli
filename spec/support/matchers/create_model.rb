module Matchers
  extend RSpec::Matchers::DSL

  matcher :create_model do |model_class|
    supports_block_expectations

    match do |action|
      expect { action.call }.to change { model_class.count }.by(1)
    end
  end
end
