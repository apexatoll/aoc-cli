module AocCli
	module Year
		class Init
			attr_reader :user, :year, :dir
			def initialize(u:Metafile.get(:user), 
						   y:, dir:".")
				@user = Validate.user(u)
				@year = Validate.year(y)
				@dir  = dir
			end
			def mkdir
				raise E::YearExist if Dir.exist?(year.to_s)
				Dir.mkdir(year.to_s)
				self
			end
			def write
				File.write(Validate.not_other_year(dir:dir, y:year), 
						   Metafile.year(y:year, d:day))
				#raise E::AlrInit if File.exist?(".meta") &&
					#Files::Metafile.get(:year) != year
				#File.write("#{dir}/.meta", meta)
			end
			#private
			#def meta
				#<<~file
				#dir=>ROOT
				#year=>#{year}
				#user=>#{user}
				#file
			#end
		end
		class Calendar < Init
			attr_reader :cal, :stats, :user, :year, :dir
			def initialize(u:Metafile.get(:user), y:, dir:".")
				@dir   = dir
				@user  = Validate.user(u)
				@year  = Validate.year(y)
				@stats = Data::Stats.new(u:user, y:year)
				@cal   = Data::Calendar
					.new(u:user, y:year)
					.fill(stars:stats.stars)
			end
			def write
				File.write("#{dir}/#{year}.md", file)
				self
			end
			def update_meta
				Metafile.add(dir:dir, hash:{
					stars:stats.stars.to_json, 
					total:stats.total_stars})
			end
			private
			def file
				text = <<~file
					Year #{year}: #{stats.total_stars}/50 *
					#{"-" * (cal.data[0].to_s.length + 2)}
					#{cal.data.join("\n")}\n
				file
				text += stats.data.join("\n") if stats.total_stars > 0
				text
			end
		end
		module Data
			class YearObject
				attr_reader :user, :year, :page, :data
				def initialize(u:Metafile.get(:user),
							   y:Metafile.get(:year))
					@user = Validate.user(u)
					@year = Validate.year(y)
					@data = parse(raw: fetch)
				end
				private
				def fetch
					Tools::Get.new(u:user, y:year, page:page).plain.split("\n")
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
					stars.each{|s, n| data.each{|l| l.gsub!(
						/(^.*)\b#{s}\b.$/, "\\1#{s}\s#{"*" * n}")}}
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
						.map{|s| [s.to_i, data.grep(
							/^.*#{s}.*(\-.*){3}$/)
						.count == 0 ? 2 : 1]}.to_h
				end
				def total_stars
					stars.values.reduce(:+).to_i || 0
				end
			end
		end
	end 
end
