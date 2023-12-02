module TempDirHelper
  attr_reader :temp_dir

  def temp_path(file)
    Pathname(temp_dir).join(file)
  end
end

RSpec.configure do |config|
  config.include TempDirHelper, with_temp_dir: true

  config.around(with_temp_dir: true) do |spec|
    Dir.mktmpdir do |temp_dir|
      @temp_dir = temp_dir

      spec.run

      remove_instance_variable(:@temp_dir)
    end
  end
end
