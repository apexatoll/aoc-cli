module AocCli
	module Year
		def self.refresh
			puts "- Updating calendar...".blue
			Year::Init.new.write
			Year::Stars.new.write.update_meta
		end
		class Init
			attr_reader :user, :year, :paths
			def initialize(u:Files::Config.new.def_acc,
						   y:Metafile.get(:year), dir:".")
				@user = Validate.user(u)
				@year = Validate.year(y)
				@paths = Files::Paths::Year.new(u:user, y:year)
			end
			def write
				File.write(paths.local(f:"meta"), 
					Metafile.year(u:user, y:year))
			end
		end
		class Stars < Init
			attr_reader :stats, :cal
			def initialize(u:Metafile.get(:user), 
						   y:Metafile.get(:year))
				super(u:u, y:y)
				@stats = Data::Stats.new(u:user, y:year)
				@cal   = Data::Calendar.new(u:user, y:year)
					.fill(stars:stats.stars)
			end
			def write
				File.write(paths.local(f:"Stars"), file)
				self
			end
			def update_meta
				Metafile.add(path:paths.local(f:"meta"), hash:{
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
			class YearObject < Init
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
			class Calendar < YearObject
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
			class Stats < YearObject
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
	end 
end
