RSpec.configure do |config|
  # Do not render views with color in request specs for clearer assertions
  config.around(type: :request) do |spec|
    String.disable_colorization = true
    spec.run
    String.disable_colorization = false
  end
end
