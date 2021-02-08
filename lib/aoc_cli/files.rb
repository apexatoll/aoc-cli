module AocCli
	module Files
		class Config
			require 'fileutils'
			def initialize
				FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
				File.write(path, "", mode:"a") unless File.exist?(path)
			end
			protected
			def has_term?(key:nil, val:nil)
				file.split("\n").grep(/#{key}=>#{val}/).any?
			end
			def add_line(key:, val:)
				File.write(path, "#{key}=>#{val}\n", mode:"a")
			end
			def file
				File.read(path)
			end
			def dir
				"#{Dir.home}/.config/aoc-cli"
			end
			def path
				"#{dir}/aoc.rc"
			end
		end
		class Cookie < Config
			attr_reader :user, :key
			def initialize(user:)
				@user = user
				super()
			end
			def store(key:)
				raise Errors::Key_Nil if key.nil?
				raise Errors::UserDup if has_term?(key:"cookie=>#{user}")
				raise Errors::KeyDup  if has_term?(val:key)
				add_line(key:"cookie=>#{user}", val:key)
			end
			def key
				file.scan(/(?<=cookie=>#{user}=>).*$/)&.first ||= raise(Errors::Key_Not_Found)
			end
		end
		class Metafile
			def self.get(field)
				read.scan(/(?<=#{field}=>).*$/)&.first&.chomp
			end
			def self.type
				read.scan(/(?<=dir=>).[A-Z]*$/).first.to_sym
			end
			def self.add(hash:, dir:".")
				hash.map {|k, v| "#{k}=>#{v}\n"}
					.each{|l| File.write("#{dir}/#{path}",l , mode:"a")}
			end
			def self.delete(keys:, dir:".")
				del = keys.map{|k| /^#{k}=>.*$/}
				new = lines(dir:dir).reject{|l| del.map{|r| r.match?(l)}.any?}.join
				write(file:new, dir:dir)
			end
			def self.get_part(day:)
				JSON.parse(read.scan(/(?<=stars=>).*$/)&.first)[day.to_s].to_i + 1
			end
			def self.path(dir:".")
				"#{dir}/.meta"
			end
			private
			def self.write(file:, dir:".")
				
			end
			def self.read(dir:".")
				raise Errors::NotInit unless File.exist?(path)
				File.read(path)
			end
			def self.lines(dir:".")
				raise Errors::NotInit unless File.exist?(path)
				File.read(path)
			end
		end
	end
end
