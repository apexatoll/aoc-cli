module AocCli 
module Tools
	class Request
		require 'curb'
		attr_reader :page, :base, :year, :day, :user
		def initialize(user:Mf.get(:user), year:Mf.get(:year),
						day:Mf.get(:day),  page:)
			@user = Val.get_user(user)
			@page = page
			#@year = year
			@year = Val.year(year)
			@day  = day
			@base = "https://adventofcode.com/#{year}"
		end
		protected
		def get
			Curl.get(url){|h| h.headers['Cookie'] = cookie}.body
		end
		def post(data:)
			Curl.post(url, data){|h| h.headers['Cookie'] = cookie}.body
		end
		private
		def cookie
			Files::Cookie.new(user:user).key
		end
		def url
			case page
			when :calendar then base 
			when :stats    then base + "/leaderboard/self"
			when :Puzzle   then base + "/day/#{day}"
			when :Input    then base + "/day/#{day}/input"
			when :answer   then base + "/day/#{day}/answer"
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
		def initialize(user:Mf.get(:user), year:Mf.get(:year),
						day:nil, page:)
			@input = Request
				.new(page:page, day:day, year:year, user:user)
				.get
		end
	end
	class Post < Convert
		def initialize(user:Mf.get(:user), year:Mf.get(:year),
						day:Mf.get(:day),  page:, data:)
			@input = Request
				.new(year:year, user:user, page:page, day:day)
				.post(data:data)
		end
	end
end end
