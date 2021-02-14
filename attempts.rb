class Attempts
	attr_reader :user, :year, :day, :part, :answer, :db
	def initialize(u:Metafile.get(:user),
				   y:Metafile.get(:year),
				   d:Metafile.get(:day),
				   p:Metafile.get(:part), a:)
		@user = Validate.user(u)
		@year = Validate.year(y)
		@day  = Validate.day(d)
		@part = Validate.part(p)
		@db = Files::Database
			.new("attempts.db")
			.table(t:user, cols:cols)
	end
	def log
		db.insert(t:user, val:data)
	end
	def cols
		{"year"=>:INT, "day"=>:INT, "part"=>:INT, "answer"=>:TEXT}
	end
	def data
		{year, day, part, answer}
	end
end
