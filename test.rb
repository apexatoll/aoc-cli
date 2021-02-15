require 'colorize'
def title(title)
	"#{title.bold}"
end
def flag(short, full)
	str = "    #{short.yellow.bold} [#{full.blue.italic}]"
	full.length > 6 ?
		str += "\t"  :
		str += "\t\t"
		#full.length <= 16 ? 
			#str += "\t" : str += ""
	str
end
#str = 
require_relative "help.rb"
#puts str
#
