module AocCli
	module Year
		def self.refresh
			puts "- Updating calendar...".blue
			Year::Meta.new.write
			Year::Progress.new.write
		end
		class Meta
			attr_reader :user, :year, :paths
			def initialize(u:Files::Config.new.default_alias,
						   y:Metafile.get(:year), dir:".")
				@user  = Validate.user(u)
				@year  = Validate.year(y)
				@paths = Paths::Year.new(u:user, y:year)
			end
			def write
				File.write(paths.local(f:"meta"), 
					Metafile.year(u:user, y:year))
			end
		end
		class Progress < Meta
			def stats
				@stats ||= Requests::Stats.new(u:user, y:year)
			end
			def cal
				@cal ||= Requests::Calendar.new(u:user, y:year)
					.fill(stars:stats.stars)
			end
			def file
				Files::Calendar.new(stats:stats, cal:cal).file
			end
			def write?
				Files::Setting.new
					.bool(key:"calendar_file", default:true)
			end
			def write
				File.write(paths.local(f:"Stars"), file) if write?
				self
			end
			def db
				Database::Calendar::Init
					.new(u:user, y:year, stars:stats.stars)
					.insert
			end
		end
		module Requests
			class Request < Meta
				attr_reader :data
				def initialize(u:Metafile.get(:user),
							   y:Metafile.get(:year))
					super(u:u, y:y)
					@data = parse(raw: fetch)
				end
				private
				def fetch
					Tools::Get.new(u:user, y:year, p:page).plain.split("\n")
				end
			end
			class Calendar < Request
				def page
					:Calendar
				end
				def parse(raw:)
					raw.drop(raw.index{|l| l =~ /\*\*/})
						.map{|l| l.gsub(/\*\*/, "")}
				end
				def fill(stars:)
					stars.each{|s, n| data.each{|l| l
						.gsub!(/(^.*)\b#{s}\b.$/, "\\1#{s}\s#{"*" * n}")}}
					self
				end
			end
			class Stats < Request
				def page
					:Stats
				end
				def parse(raw:)
					/You haven't collected/.match?(raw.to_s) ?
						raw : raw.drop(raw.index{|l| l =~ /^.*Part 1/}) 
				end
				def stars
					data.map{|l| l.scan(/^\s+\d+/)&.first}
						.reject{|s| s == nil}
						.map{|s| [s.to_i, data
						.grep(/^.*#{s}.*(\-.*){3}$/)
						.count == 0 ? 2 : 1]}.to_h
				end
				def total_stars
					stars.values.reduce(:+).to_i || 0
				end
			end
		end
		class GitWrap
			require 'git'
			def initialize()
			end
			def init
				git = Git.init
				File.write(".gitignore", ignore)
				git.add(".gitignore")
			end
			def ignore
				<<~ignore
				*.md
				**/*.md
				.meta
				**/.meta
				ignore
			end
		end
	end 
end
