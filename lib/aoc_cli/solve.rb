module AocCli
	module Solve
		CORRECT   = "That's the right answer"
		INCORRECT = "That's not the right answer"
		WAIT      = "You gave an answer too recently"
		class Solve
			attr_reader :user, :year, :day, :part, :answer, :reply
			def initialize(u:Metafile.get(:user), 
						   y:Metafile.get(:year),
						   d:Metafile.get(:day),
						   p:Metafile.get(:part), a:)
				@user   = Validate.set?(k: :u, v:u)
				@answer = Validate.set?(k: :a, v:a)
				@year   = Validate.year(y)
				@day    = Validate.day(d)
				@part   = Validate.part(p)
				@reply  = parse(attempt:send)
			end
			def respond
				case reply
				when /#{INCORRECT}/ then Responses::Incorrect
					.new(u:user, y:year, d:day, p:part, a:answer)
					.log.response
				when /#{WAIT}/ then Responses::Wait
					.new(u:user, y:year, d:day, p:part, a:answer)
					.response
				when /#{CORRECT}/ then Responses::Correct
					.new(u:user, y:year, d:day, p:part, a:answer)
					.response.refresh
				end
			end
			def send
				Tools::Post
					.new(page: :answer, y:year, d:day, data:data)
			end
			def parse(attempt:)
				attempt.chunk(f:"<main", t:"<\/main", t_off:1)
					.plain
					.gsub("\n", " ")
					.gsub(/\s+\[.*\]/, "")
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
					File.write(".attempts", 
						"#{{Time.new => answer}.to_json}\n",
						mode:"a")
					self
				end
			end
			class Correct < Solve
				def response
					msg = "#{"Correct!".bold.green} "
					case part
					when "1" then msg += next_part
					when "2" then msg += complete end
					puts msg
					self
				end
				def refresh
					refresh_calendar
					refresh_puzzle
					self
				end
				private 
				def next_part
					"Downloading part two.."
				end
				def complete
					"This day is now complete!".green
				end
				def refresh_calendar
					puts "- Updating calendar...".blue
					Year::Meta
						.new(y:year, dir:"..").write
					Year::Calendar
						.new(y:year, dir:"..").write.update_meta
				end
				def refresh_puzzle
					puts "- Updating puzzle...".yellow
					Day::Init.new(d:day).write
					Day::Data::Puzzle.new(d:day).write
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
