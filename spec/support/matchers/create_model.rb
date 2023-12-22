module Matchers
  extend RSpec::Matchers::DSL

  matcher :create_model do |model_class|
    supports_block_expectations

    match do |action|
      count_before = model_class.count
      action.call
      count_after = model_class.count

      created = count_after - count_before == 1

      return created unless @attributes

      expect(model_class.last).to have_attributes(**@attributes)
    end

    chain :with_attributes do |attributes|
      @attributes = attributes
    end
  end
end
