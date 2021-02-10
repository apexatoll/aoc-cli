module AocCli
	module Solve
		#Const
		CORRECT   = "That's the right answer"
		INCORRECT = "That's not the right answer"
		WAIT      = "You gave an answer too recently"
		class Solve
			attr_reader :user, :year, :day, :part, :answer, :reply
			def initialize(answer:,
				year:Files::Metafile.get(:year),
				day: Files::Metafile.get(:day),
				part:Files::Metafile.get(:part),
				user:Files::Metafile.get(:user))
				@user   = user ||= raise Errors::UserNil
				@answer = answer ||= raise Errors::AnsNil
				@day    = Interface::Validate.day(day)
				@part   = Interface::Validate.part(part)
				@year   = Interface::Validate.year(year)
				@reply  = parse(attempt:send)
			end
			def respond
				case reply
				when /#{INCORRECT}/ then Responses::Incorrect
					.new(answer:answer, year:year, day:day, part:part, user:user)
					.log
					.response
				when /#{WAIT}/ then Responses::Wait
					.new(answer:answer, year:year, day:day, part:part, user:user)
					.response
				when /#{CORRECT}/ then Responses::Correct
					.new(answer:answer, year:year, day:day, part:part, user:user)
					.response
					.refresh
				end
			end
			#private
			def send
				Tools::Post.new(page: :answer, year:year, day:day, data:data)
			end
			def parse(attempt:)
				attempt.chunk(f:"<main", t:"<\/main", t_off:1)
					.plain.gsub("\n", " ").gsub(/\s+\[.*\]/, "")
			end
			def data
				{level:part, answer:answer}
			end
		end
		module Responses
			class Incorrect < Solve
				def high
					/too high/.match?(reply)
				end
				def low
					/too low/.match?(reply)
				end
				def response
					text = <<~response
					#{"Incorrect".red.bold}: You guessed - #{answer.to_s.red}
					response
					text += "This answer is too high\n" if high
					text += "This answer is too low\n"  if low
					puts text
					self
				end
				def log
					File.write(".attempts", "#{{Time.new => answer}
						.to_json}\n", mode:"a")
					self
				end
			end
			class Correct < Solve
				def refresh
					refresh_calendar
					refresh_puzzle
					self
				end
				def response
					msg = "#{"Correct!".bold.green} "
					case part
					when "1" then msg += get_part_2
					when "2" then msg += now_complete end
					puts msg
					self
				end
				private 
				def get_part_2
					"Downloading part two.."
				end
				def now_complete
					"This day is now complete!".green
				end
				def refresh_calendar
					puts "- Updating calendar...".blue
					Year::Meta.new(user:user, year:year, dir:"..").write
					Year::Calendar.new(dir:"..", year:year).write.update_meta
				end
				def refresh_puzzle
					puts "- Updating puzzle...".yellow
					Day::Init.new(day:day).write
					Day::Data::Puzzle.new(day:day).write
				end
			end
			class Wait < Solve
				def response
					puts <<~response
					#{"Please wait".yellow.bold}: You have #{time.to_s} to wait
					response
					self
				end
				def time
					reply.scan(/(?:\d+m\s)?\d+s/).first.to_s
				end
			end
		end
	end
end
