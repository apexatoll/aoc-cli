module AocCli
	module Files
		module Config
			class Tools
				def self.is_set?(key:nil, val:nil)
					read.split("\n").grep(/(?<!\/\/)#{key}=>#{val}/).any?
				end
				def self.get_all(key:)
					read.scan(/(?:(?<=(?<!\/\/)#{key}=>)).*$/)
				end
				def self.get_line(key:)
					get_all(key:key)&.first
					#read.scan(/(?:(?<=(?<!\/\/)#{key}=>)).*$/)&.first
				end
				def self.get_bool(key:)
					get_line(key:key) == "true" ? true : false
				end
				def self.mod_line(key:, val:)
					is_set?(key:key) ?
						write(f:read.gsub(/(?<=^#{key}=>).*$/, val.to_s)) :
						write(f:"#{key}=>#{val}\n", m:"a")
				end
				def self.set_line(key:, val:)
					write(f:"#{key}=>#{val}\n", m:"a")
				end
				private
				def self.read
					Paths::Config.create
					File.read(Paths::Config.path)
				end
				def self.write(f:, m:"w")
					Paths::Config.create
					File.write(Paths::Config.path, f, mode:m)
				end
			end
			class Prefs < Tools
				def self.default_alias
					is_set?(key:"default") ? get_line(key:"default") :
						is_set?(key:"cookie=>main") ? "main" :
							list_aliases.first || "main"
				end
				def self.list_aliases
					get_all(key:"cookie")&.map{|a| a.gsub(/=>.*/, "")}
				end
				def self.bool(key:)
					is_set?(key:key) ?  
						get_bool(key:key) : defaults[key.to_sym]
				end
				def self.string(key:)
					is_set?(key:key) ? 
						get_line(key:key) : defaults[key.to_sym]
				end
				private
				def self.defaults
					{ calendar_file:true,
					  ignore_md_files:true,
					  ignore_meta_files:true,
					  init_git:false,
					  lb_in_calendar:true,
					  reddit_in_browser:false,
					  unicode_tables:true
					}
				end
			end
			class Cookie < Tools
				def self.store(user:, key:)
					set_line(key:"cookie=>#{Validate.set_user(user)}",
							 val:Validate.set_key(key))
				end
				def self.key(user:)
					Validate.key(get_line(key:"cookie=>#{Validate
						.user(user)}"))
				end
			end
			class Example
				def self.write
					File.write(Validate.no_config, file)
				end
				def self.file
					<<~file
					//aoc-cli example config
					//See the github repo for more information on configuring aoc-cli
					//https://github.com/apexatoll/aoc-cli
					
					[General]
					//Print table in unicode rather than ascii
					unicode_tables=>true
					//Open Reddit in browser rather than use a Reddit CLI
					reddit_in_browser=>false
					
					[Initialise Year]
					//Create a calendar file 
					calendar_file=>true
					//Initialise git repo on year initialisation
					init_git=>false
					//Add calendar and puzzle files to gitignore
					ignore_md_files=>true
					//Add .meta files to gitignore
					ignore_meta_files=>true
					//Include leaderboard stats in calendar file
					lb_in_calendar=>true
					file
				end
			end
		end
		class Metafile
			def self.get(field)
				read.scan(/(?<=#{field}=>).*$/)&.first&.chomp
			end
			def self.type
				get("dir").to_sym
			end
			def self.part(d:)
				Database::Calendar::Part.new(d:d).get
			end
			private
			def self.read(dir:".")
				File.read("#{Validate.init(dir)}/.meta")
			end
			def self.year(u:, y:)
				<<~meta
				dir=>ROOT
				user=>#{u}
				year=>#{y}
				meta
			end
			def self.day(u:, y:, d:)
				<<~meta
				dir=>DAY
				user=>#{u}
				year=>#{y}
				day=>#{d}
				part=>#{part(d:d)}
				meta
			end
		end
		class Calendar
			attr_reader :cal, :stats, :year
			def initialize(y:Metafile.get(:year), cal:, stats:)
				@year, @cal, @stats  = Validate.year(y), cal, stats
			end
			def include_leaderboard?
				Prefs.bool(key:"lb_in_calendar")
			end
			def title
				"Year #{year}: #{stats.total_stars}/50 *"
			end
			def underline
				"-" * (cal.data[0].to_s.length + 2)
			end
			def make
				<<~file
					#{title}
					#{underline}
					#{cal.data.join("\n")}\n
					#{stats.data.join("\n") if stats.total_stars > 0 &&
						include_leaderboard?}
				file
			end
		end
	end 
end
