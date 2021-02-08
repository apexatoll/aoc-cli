module AocCli
	module Year
		class Meta
			attr_reader :user, :year
			def initialize(user:"main", year:)
				@user, @year = user, Interface::Validate.year(year)
			end
			def write
				raise Errors::AlrInit if File.exist?(".meta")
				File.write(".meta", meta)
			end
			private
			def meta
				<<~file
				dir=>ROOT
				year=>#{year}
				user=>#{user}
				file
			end
		end
		class Calendar
			attr_reader :cal, :stats, :user, :year, :path
			def initialize(
				user:Files::Metafile.get(:user), 
				year:, 
				path:".")
				@user, @year = user, year
				@path = path
				@stats = Data::Stats.new(user:user, year:year)
				@cal = Data::Calendar.new(user:user, year:year)
					.fill(stars:stats.stars)
			end
			def write
				File.write("#{path}/#{year}.md", file)
				self
			end
			def update_meta
				Files::Metafile.add(hash:{stars:stats.stars.to_json, total:stats.total_stars})
			end
			private
			def file
				<<~file
					Year #{year}: #{stats.total_stars}/50 *
					#{"-" * (cal.data[0].to_s.length + 2)}
					#{cal.data.join("\n")}\n
					#{stats.data.join("\n")}
				file
			end
		end
		module Data
			class YearObject
				attr_reader :user, :year, :page, :data
				def initialize(user:Files::Metafile.get(:user),
							   year:Files::Metafile.get(:year))
					@user, @year = user, year
					@data = parse(raw: fetch)
				end
				private
				def fetch
					Tools::Get.new(user:user, year:year, page:page).plain.split("\n")
				end
			end
			class Calendar < YearObject
				def page
					:calendar
				end
				def parse(raw:)
					raw.drop(raw.index{|l| l =~ /\*\*/})
						.map{|l| l.gsub(/\*\*/, "")}
				end
				def fill(stars:)
					stars.each{|s, n| data.each{|l|
						l.gsub!(/(^.*)\b#{s}\b.$/, "\\1#{s}\s#{"*" * n}")}}
					self
				end
			end
			class Stats < YearObject
				def page
					:stats
				end
				def parse(raw:)
					/You haven't collected/.match?(raw.to_s) ?
						raw : raw.drop(raw.index{|l| l =~ /^.*Part 1/}) 
				end
				def stars
					data.map{|l| l.scan(/^\s+\d+/)&.first}
						.reject{|s| s == nil}
						.map{|s| [s.to_i, data.grep(/^.*#{s}.*(\-.*){3}$/)
						.count == 0 ? 2 : 1]}.to_h
				end
				def total_stars
					stars.values.reduce(:+).to_s ||= 0
				end
			end
		end
	end
end
