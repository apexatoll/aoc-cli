module TempDirHelper
  extend RSpec::Matchers::DSL

  attr_reader :temp_dir

  def temp_path(file)
    Pathname(temp_dir).join(file)
  end

  matcher :create_temp_dir do |dir|
    supports_block_expectations

    match do |action|
      path = temp_path(dir)
      exists_before = Dir.exist?(path)
      action.call
      exists_after = Dir.exist?(path)

      !exists_before && exists_after
    end
  end

  matcher :create_temp_file do |file|
    supports_block_expectations

    match do |action|
      path = temp_path(file)

      exists_before = File.exist?(path)
      action.call
      exists_after = File.exist?(path)

      created = !exists_before && exists_after

      return created unless @contents

      if @contents.is_a?(Proc)
        created && File.read(path) == @contents.call
      else
        created && File.read(path) == @contents
      end
    end

    chain :with_contents do |contents = nil, &block|
      @contents = contents || block
    end
  end

  matcher :update_temp_file do |file|
    supports_block_expectations

    match do |action|
      path = temp_path(file)

      value_before = File.read(path)
      action.call
      value_after = File.read(path)

      updated = value_after != value_before

      return updated unless @contents

      if @contents.is_a?(Proc)
        updated && value_after == @contents.call
      else
        updated && value_after == @contents
      end
    end

    chain :to do |contents = nil, &block|
      @contents = contents || block
    end
  end
end

RSpec.configure do |config|
  config.include TempDirHelper, with_temp_dir: true

  config.around(with_temp_dir: true) do |spec|
    env_key = "TMPDIR"
    tmpdir_before = ENV.fetch(env_key, nil)

    ENV[env_key] = spec_dir.join("tmp").tap do |dir|
      dir.mkdir unless dir.exist?
    end.to_s

    Dir.mktmpdir do |temp_dir|
      Dir.chdir(temp_dir) do
        @temp_dir = temp_dir

        spec.run

        remove_instance_variable(:@temp_dir)
      end
    end

    ENV[env_key] = tmpdir_before
  end
end
