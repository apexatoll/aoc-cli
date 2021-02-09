module AocCli
	module Cache
		class Directory
			require 'fileutils'
			protected
			attr_reader :user, :year, :day, :pages
			def initialize(user:Files::Metafile.get(:user), 
						   year:Files::Metafile.get(:year), 
						    day:Files::Metafile.get(:day),
						  pages:[:Input, :Puzzle])
				@user = user
				@year = year
				@day = day
				@pages = pages
				FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
			end
			protected
			def dir
				"#{Dir.home}/.cache/aoc-cli/#{user}/#{year}/#{get_day}"
			end
			def get_day
				day.to_i < 10 ? "0#{day}" : day.to_s
			end
		end
		class Query < Directory
			attr_reader :store
			def get
				@store = pages.map{|p| [p, get_page(page:p)]}.to_h
				self
			end
			#def path(page:)
				#"#{dir}/#{get_day}/#{page_path(page:page)}"
			#end
			def path(page:)
				case page
				when :Input  then "#{dir}/input"
				when :Puzzle then "#{dir}/#{day}.md"
				end 
			end
			private
			def get_page(page:)
				File.exist?(path(page:page)) ? 
					File.read(path(page:page)) : nil
			end
			#def exist?(page:)
				#File.exist?(path(page:page))
			#end
		end
	end
end
#module AocCli
	#module Day
		#class DayFiles < Cache::Query
			#attr_reader :user, :year, :day, :cache
			#def initialize(user:, year:, day:, pages:[:Input, :Puzzle])
				#@user, @year, @day = user, year, day
				##@year = year
				##@day  = day
				##@user = Interface::Validate.user(user)
				##@year = Interface::Validate.year(year)
				##@day  = Interface::Validate.day(day)
				#@cache = Cache::Query
					#.new(user:user, year:year, day:day, pages:pages).get
			#end
			#def write
				#cache.store.each do |page, data|
					#if data
						##here the data is loaded from the cache
						##query and written to the day directory
						#File.write(local_path(page:page), data)
					#else
						##page.each do |p|
						#download(page:p, paths:[cache.path(page:p), local_path(page:p)])
						##end
						##data.each{|d| }
						##here the data must be downloaded and stored in both the cache and the local dir
						#puts "this file #{k} does not exist"
						#puts "it shou#{cache.path(page:k)}"
						#puts "and in #{local_path(page:k)}"
					#end
				#end
			#end
			#private
			#def download(page:, paths:)
				#Object.const_get("Day::Data::#{page}")
					#.new(user:user, year:year, day:day)
					#.write(paths:paths)
			#end
			#def local_path(page:)
				#"#{dir}/#{cache.path(page:page)}"
			#end
			#def dir
				#Files::Metafile.type == :DAY ? "." : day.to_i < 10 ?
					#"0#{day}" : day.to_s
				##"."
			#end
		#end
	#end
#end
##AocCli::Day::Files.new(user: "main", year: 2015, day: 13).write
