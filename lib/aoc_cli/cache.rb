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
				"#{Dir.home}/.cache/aoc-cli/#{user}/#{year}/#{day}"
			end
		end
		class Query < Directory
			attr_reader :store
			def get
				@store = pages.map{|p| [p, exist?(page:p) ? 
					get_page(page:p) : false]}.to_h
				self
			end
			def path(page:)
				"#{dir}/#{day}/#{page_path(page:page)}"
			end
			def page_path(page:)
				case page
				when :Input  then "input"
				when :Puzzle then "#{day}.md"
				end 
			end
			private
			def get_page(page:)
				File.read(path(page:page))
			end
			def exist?(page:)
				File.exist?(path(page:page))
			end
		end
	end
end
module AocCli
	module Day
		class Files
			attr_reader :user, :year, :day, :cache
			def initialize(user:, year:, day:, pages:[:Input, :Puzzle])
				@user = user
				@year = year
				@day  = day
				#@user = Interface::Validate.user(user)
				#@year = Interface::Validate.year(year)
				#@day  = Interface::Validate.day(day)
				@cache = Cache::Query.new(user:user, year:year, day:day, pages:pages).get
			end
			def write
				cache.store.each do |page, data|
					if data
						File.write(local_path(page:page), data)
					else
						puts "this file #{k} does not exist"
						puts "it shou#{cache.path(page:k)}"
						puts "and in #{local_path(page:k)}"
					end
				end
			end
			private
			def download(page:, path:)
				Object.const_get("Day::Data::#{page}")
					.new(user:user, year:year, day:day)
					.write
			end
			def cache_copy


			end
			def get_input

			end
			def local_path(page:)
				"#{dir}/#{cache.page_path(page:page)}"
			end
			def dir
				#Files::Metafile.type == :DAY ? "." : "#{day}"
				"."
			end
		end
	end
end
AocCli::Day::Files.new(user: "main", year: 2015, day: 13).write
