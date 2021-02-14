require 'colorize'
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
			@user, @year, @day, @part, @answer = u, y, d, p, a
			#@user   = Validate.user(u)
			#@year   = Validate.year(y)
			#@day    = Validate.day(d)
			#@part   = Validate.part(p)
			#@answer = Validate.ans(a)
		end
		def raw
			#"That's the right answer"
			"That's not the right answer"
			#@raw ||= Tools::Post
				#.new(u:user, y:year, d:day, 
					 #data:{level:part, answer:answer})
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
				.const_get("Solve::Respond::#{check}")
				.new(attempt:self)
				.react
		end
	end
	module Respond
		class Response
			attr_reader :attempt
			def initialize(attempt:)
				@attempt = attempt
				puts attempt.user
			end
		end
		class Correct < Response
			def react
				respond
				Year.refresh
				log
			end
			def respond
				response = "#{"Correct!".bold.green} "
				response += case attempt.part
					when "1" then next_part
					when "2" then complete end
				puts response
				self
			end
			def refresh
				refresh_calendar
				refresh_puzzle
				self
			end
			private 
			def log
				Log.new(attempt:attempt).correct
			end
			def next_part
				"Downloading part two.."
			end
			def complete
				"This day is now complete!".green
			end
			def refresh_calendar
				puts "- Updating calendar...".blue
				Year::Init.new.write
				Year::Stars.new.write.update_meta
			end
			def refresh_puzzle
				puts "- Updating puzzle...".yellow
				Day::Init.new.write
				Day::Data::Puzzle.new.write
			end
		end
		class Incorrect < Response
			def react
				self.respond.log
			end
			protected
			def respond
				response =  "#{"Incorrect".red.bold}: "\
					"You guessed - #{attempt.answer.to_s.red}\n"
				response += "This answer is too high\n" if high
				response += "This answer is too low\n"  if low
				puts response
				self
			end
			def log
				Log.new(attempt:attempt).incorrect
			end
			def high
				/too high/.match?(attempt.raw)
			end
			def low
				/too low/.match?(attempt.raw)
			end
		end
		class Log
			attr_reader :attempt
			def initialize(attempt:)
				@attempt = attempt
				#@db ||= Files::Database.new("attempts.db")
					#.table(t:user, cols:cols)
			end
			def insert
				#db.insert(t:user, val:data)
			end
			def incorrect
				puts attempt.answer
			end
			def data
				[attempt.year, attempt.day, attempt.part, attempt.answer]
			end
			def cols
				{"year"=>:INT, "day"=>:INT, "part"=>:INT, "answer"=>:TEXT}
			end
		end
	end
end

Solve::Attempt.new(u: "main", y: 2020, d: 10, p: 2, a: :klsdfa).respond





































#module Responses
	#class Response < Solve
		#attr_reader :input
		#def initialize(input:, u:, y:, d:, p:, a:)
			#super(u:u, y:y, d:d, p:p, a:a)
			#@input = input
		#end
		#def react
			#puts response
			#self
		#end
	#end
	#class Log < Response
		#def db
			#@db ||= Files::Database.new("attempts.db")
				#.table(t:user, cols:cols)
		#end
		#def log
			#db.insert(t:user, val:data)
		#end
		#def data
			#{year, day, part, answer}
		#end
		#def cols
			#{"year"=>:INT,
			 #"day"=>:INT, 
			 #"part"=>:INT, 
			 #"answer"=>:TEXT}
		#end
	#end
	#class Incorrect < Response
		#def response
			#msg =  "#{"Incorrect".red.bold}: "\
					#"You guessed - #{answer.to_s.red}\n"
			#msg += "This answer is too high\n" if high
			#msg += "This answer is too low\n"  if low
			#msg
		#end
		#def high
			#/too high/.match?(input)
		#end
		#def low
			#/too low/.match?(input)
		#end
	#end
	#class Correct < Response
		#def response
			#msg = "#{"Correct!".bold.green} "
			#msg += case part
			#when "1" then next_part
			#when "2" then complete 
			#end
			#msg
		#end
		#def refresh
			#refresh_calendar
			#refresh_puzzle
			#self
		#end
		#private 
		#def next_part
			#"Downloading part two.."
		#end
		#def complete
			#"This day is now complete!".green
		#end
		#def refresh_calendar
			#puts "- Updating calendar...".blue
			#Year::Init.new.write
			#Year::Stars.new.write.update_meta
		#end
		#def refresh_puzzle
			#puts "- Updating puzzle...".yellow
			#Day::Init.new.write
			#Day::Data::Puzzle.new.write
		#end
	#end
	#class Wait < Response
		#def response
			#"#{"Please wait".yellow.bold}: "\
			#"You have #{time.to_s} to wait"
		#end
		#def time
			#reply.scan(/(?:\d+m\s)?\d+s/).first.to_s
		#end
	#end
#end
