module Matchers
  extend RSpec::Matchers::DSL

  matcher :render_component do |component_class|
    supports_block_expectations

    match do |action|
      component_double = instance_double(component_class, render: nil)

      allow(component_class).to receive(:new).and_return(component_double)

      expect(component_class).not_to have_received(:new)

      action.call

      if @with
        expect(component_class).to have_received(:new).with(@with)
      else
        expect(component_class).to have_received(:new)
      end

      expect(component_double).to have_received(:render).once
    end

    chain :with do |with|
      @with = with
    end
  end
end
