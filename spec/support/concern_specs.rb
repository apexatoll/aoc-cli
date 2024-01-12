RSpec.configure do |config|
  file_path = %r{spec/.*/controllers/concerns/}

  config.define_derived_metadata(file_path:) do |metadata|
    metadata[:type] = :concern
  end

  config.include ConcernHelpers, type: :concern
end
