module AocCli
	module Solve
		#Const
		CORRECT   = "That's the right answer"
		INCORRECT = "That's not the right answer"
		WAIT      = "You gave an answer too recently"
		class Solve
			attr_reader :user, :year, :day, :part, :answer, :reply
			def initialize(answer:,
				year:Metafile.new.get(:year),
				day: Metafile.new.get(:day),
				part:Metafile.new.get(:part),
				user:Metafile.new.get(:user))
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
			private
			def send
				Tools::Post.new(page: :answer, day:day, data:data)
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
					File.write(".attempts", "#{{Time.new => answer}.to_json}\n", mode:"a")
					self
				end
			end
			class Correct < Solve
				def refresh
					puts "Refreshing calendar...".yellow
					Year::Calendar
						.new(path:"..", year:Files::Metafile.get(:year))
						.write
						.update_meta
					puts "Refreshing puzzle...".yellow
					Day::Data::Puzzle
						.new(user:Files::Metafile.get(:user),
							 year:Files::Metafile.get(:year),
							  day:Files::Metafile.get(:day), 
							  dir:".")
						.write
					self
				end
				def inc_part
					
					self
				end
				def response
					puts <<~response
					#{"Correct!".bold.green}: your puzzle and calendar will now be updated.
					response
					self
				end
			end
			class Wait
				def response
					puts <<~response
					#{"Please wait".yellow.bold}: You have #{time.to_s} to wait
					response
					self
				end
				def time
					reply.scan(/\d+m \d+s/).first.to_s
				end
			end
		end
	end
end
