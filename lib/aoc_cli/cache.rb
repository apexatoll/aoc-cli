module AocCli
	module Cache
class Directory
	require 'fileutils'
	attr_reader :user, :year, :day, :files, :paths
	def initialize(user:Files::Metafile.get(:user), 
				   year:Files::Metafile.get(:year), 
					day:Files::Metafile.get(:day),
				  files:[:Input, :Puzzle])
		@user  = user
		@year  = Interface::Validate.year(year)
		@day   = Interface::Validate.day(day)
		@paths = Files::Paths.new(user:user, year:year, day:day)
		@files = files
		FileUtils.mkdir_p(paths.cache_dir) unless Dir.exist?(paths.cache_dir)
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
		cached?(file:file) ? File.read(path(file:file)) : nil
	end
	def cached?(file:)
		File.exist?(path(file:file))
	end
end end
end
