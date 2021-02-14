class Test
	def run
		one.two
	end
	def one
		puts "hello"
		self
	end
	def two
		puts "world"
		self
	end
end
Test.new.run
