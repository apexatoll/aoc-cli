module AocCli
	module Solve
		CORRECT   = "That's the right answer"
		INCORRECT = "That's not the right answer"
		WAIT      = "You gave an answer too recently"
		class Attempt
			attr_reader :user, :year, :day, :part, :answer
			def initialize(u:Metafile.get(:user),
						   y:Metafile.get(:year),
						   d:Metafile.get(:day),
						   p:Metafile.get(:part), a:)
				@user   = Validate.user(u)
				@year   = Validate.year(y)
				@day    = Validate.day(d)
				@part   = Validate.part(p)
				@answer = Validate.ans(a)
			end
			def raw
				@raw ||= Tools::Post
					.new(u:user, y:year, d:day, 
						 data:{level:part, answer:answer})
					.plain
			end
			def check
				case raw
				when /#{CORRECT}/   then :Correct
				when /#{INCORRECT}/ then :Incorrect
				when /#{WAIT}/      then :Wait
				end
			end
			def respond
				Object
					.const_get("AocCli::Solve::Respond::#{check}")
					.new(attempt:self)
					.respond
					.react
			end
		end
		module Respond
			class Response
				attr_reader :attempt
				def initialize(attempt:)
					@attempt = attempt
				end
			end
			class Correct < Response
				def react
					Year.refresh
					Day.refresh
					Files::Database::Log.new(attempt:attempt).correct
				end
				def respond
					response = "#{"Correct!".bold.green} "
					response += case attempt.part
						when "1" then next_part
						when "2" then complete end
					puts response
					self
				end
				private 
				def next_part
					"Downloading part two.."
				end
				def complete
					"This day is now complete!".green
				end
			end
			class Incorrect < Response
				def react
					Database::Log
						.new(attempt:attempt)
						.incorrect(high:high, low:low)
				end
				def respond
					response =  "#{"Incorrect".red.bold}: "\
						"You guessed - #{attempt.answer.to_s.red}\n"
					response += "This answer is too high\n" if high
					response += "This answer is too low\n"  if low
					puts response
					self
				end
				def high
					/too high/.match?(attempt.raw)
				end
				def low
					/too low/.match?(attempt.raw)
				end
			end
			class Wait < Response
				def respond
					response = "#{"Please wait".yellow.bold}: "\
								"You have #{time.to_s} to wait"
					puts response
					self
				end
				def time
					attempt.raw.scan(/(?:\d+m\s)?\d+s/).first.to_s
				end
				def react; end
			end
		end
	end
end
