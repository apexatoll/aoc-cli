module AocCli
module Database
	require 'sqlite3'
	class Query
		attr_reader :db
		def initialize(name:)
			@db = SQLite3::Database.open(name)
		end
		def select(table:, col:nil, val:nil)
			db.execute("SELECT * FROM #{table}"\
					   "WHERE #{col} = #{val}")
		end
	end
end end
