RSpec.configure do |config|
  file_path = %r{spec/.*/helpers/}

  config.define_derived_metadata(file_path:) do |metadata|
    metadata[:type] = :helper
  end

  config.include HelperHelpers, type: :helper
end
