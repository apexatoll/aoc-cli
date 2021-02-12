module AocCli
	module Cache
		class Directory
			require 'fileutils'
			attr_reader :user, :year, :day, :files, :paths
			def initialize(u:Files::Metafile.get(:user), 
						   y:Files::Metafile.get(:year),
						   d:Files::Metafile.get(:day),
						   f:[:Input, :Puzzle])
				@user  = Validate.get_user(u)
				@year  = Validate.year(y)
				@day   = Validate.day(d)
				@paths = Files::Paths.new(u:user, y:year, d:day)
				@files = f
				FileUtils.mkdir_p(paths.cache_dir) unless Dir
					.exist?(paths.cache_dir)
			end
		end
		class Query < Directory
			attr_reader :store
			def get
				@store = files.map{|f| [f, get_file(file:f)]}.to_h
				self
			end
			def path(file:)
				paths.cache_path(file:file)
			end
			private
			def get_file(file:)
				cached?(file:file) ? 
					File.read(path(file:file)) : nil
			end
			def cached?(file:)
				File.exist?(path(file:file))
			end
		end
	end 
end
