module AocCli 
	module Tools
		class Request
			require 'curb'
			attr_reader :user, :year, :day, :base, :page, :ua
			def initialize(u:Metafile.get(:user),
						   y:Metafile.get(:year),
						   d:Metafile.get(:day), p:)
				@user = Validate.user(u)
				@year = Validate.year(y)
				@day  = d
				@page = p
				@base = "https://adventofcode.com/#{year}"
				#@ua   = "github.com/apexatoll/aoc-cli"
			end
			protected
			def get
				Curl.get(url) do |h| 
					h.headers['Cookie']     = cookie
					#h.headers['User-Agent'] = ua
				end.body
			end
			def post(data:)
				Curl.post(url, data) do |h| 
					h.headers['Cookie']     = cookie
					#h.headers['User-Agent'] = ua
				end.body
			end
			private
			def cookie
				Files::Config::Cookie.key(user:user)
			end
			def url
				case page.to_sym
				when :Calendar then base 
				when :Stats    then base + "/leaderboard/self"
				when :Puzzle   then base + "/day/#{day}"
				when :Input    then base + "/day/#{day}/input"
				when :Answer   then base + "/day/#{day}/answer"
				end
			end
		end
		class Convert < Request
			require 'pandoc-ruby'
			attr_accessor :input
			def array
				input.split("\n")
			end
			def chunk(f:, t:, t_off:0, f_off:0)
				pt1 = array.index {|l| l =~ /#{f}/} + t_off
				pt2 = array.rindex{|l| l =~ /#{t}/} + f_off
				@input = array.slice(pt1, pt2 - pt1).join("\n")
				self
			end
			def raw
				input.split("\n").join("\n")
			end
			def plain
				PandocRuby.new(input, f: html, t: :plain).convert
			end
			def md
				PandocRuby.new(input, {f: html, t: :gfm}, 
				   md_head, md_ref).convert
			end
			private 
			def html
				"html-native_divs-native_spans"
			end
			def md_head
				"--markdown-headings=setext"
			end
			def md_ref
				"--reference-links"
			end
		end
		class Get < Convert
			def initialize(u:Metafile.get(:user),
						   y:Metafile.get(:year), d:nil, p:)
				@input = Request.new(u:u, y:y, d:d, p:p).get
			end
		end
		class Post < Convert
			def initialize(u:Metafile.get(:user), 
						   y:Metafile.get(:year),
						   d:Metafile.get(:day), 
						   p:"Answer", data:)
				@input = Request
					.new(u:u, y:y, d:d, p:p)
					.post(data:data)
			end
		end
		class Reddit
			attr_reader :year, :day, :uniq, :browser
			def initialize(y:Metafile.get(:year), 
						   d:Metafile.get(:day), 
						   b:Prefs.bool(key:"reddit_in_browser"))
				@year = Validate.year(y)
				@day  = Validate.day(d)
				@uniq = Database::Query
					.new(path:Paths::Database.root("reddit"))
					.select(t:"'#{year}'", where:{day:"'#{day}'"})
					.flatten[1]
				@browser = b
			end
			def open
				system("#{browser ? "open" : cmd} #{link}")
			end
			def cmd
				["ttrv", "rtv"]
					.map{|cli| cli unless `which #{cli}`.empty?}
					.reject{|cmd| cmd.nil?}&.first || "open"
			end
			def link
				"https://www.reddit.com/r/"\
				"adventofcode/comments/#{uniq}/"\
				"#{year}_day_#{day}_solutions"
			end
		end
	end 
end
