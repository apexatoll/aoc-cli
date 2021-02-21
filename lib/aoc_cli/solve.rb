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
				@raw ||= Tools::Post.new(u:user, y:year, d:day, 
					 data:{level:part, answer:answer}).plain
			end
			def check
				case raw
				when /#{CORRECT}/   then :Correct
				when /#{INCORRECT}/ then :Incorrect
				when /#{WAIT}/      then :Wait
				end
			end
			def respond
				Respond.const_get(check)
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
					Database.correct(attempt:attempt)
					Year.refresh
					Day.refresh(files:[:Puzzle])
				end
				def respond
					puts <<~response
					#{"Correct!".bold.green} #{ 
					case attempt.part
					when "1" then "Downloading part two..."
					when "2" then "This day is now complete!".green
					end }
					response
					self
				end
			end
			class Incorrect < Response
				def react
					Database::Attempt
						.new(attempt:attempt)
						.incorrect(high:high, low:low)
				end
				def respond
					puts <<~response
					#{"Incorrect".red.bold}: You guessed - #{attempt
						.answer.to_s.red} #{
					high ? "(too high)" : 
					low  ? "(too low)"  : ""}
					#{"Please wait".yellow} #{wait_time} before answering again
					response
					self
				end
				def high
					/too high/.match?(attempt.raw)
				end
				def low
					/too low/.match?(attempt.raw)
				end
				def wait_time
					attempt.raw.scan(/(?:(one minute|\d+ minutes))/)
						.first.first.to_s
				end
			end
			class Wait < Response
				def respond
					puts <<~response
					#{"Please wait".yellow.bold}: #{time.to_s} 
					response
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
