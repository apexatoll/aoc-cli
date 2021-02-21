def title(title)
	"#{title.bold}"
end
def flag(short, full)
	str = "    #{short.yellow.bold} [#{full.blue.italic}]"
	full.length > 6 ?
		str += "\t"  :
		str += "\t\t"
	str
end

help = <<~help
Advent of Code - cli, version #{AocCli::VERSION}
#{"C. Welham Feb 2021".italic}

#{title("Usage")}
#{"    aoc".bold + " -flag".italic.yellow + " value".bold.blue}

#{title("Setup")}
- Store session cookie keys to access AoC

#{flag("-k","--key")}Store a session cookie to use the cli.
#{flag("-u","--user")}Set alias for key (default: "main")
#{flag("-U","--default")}Get/set default alias
#{flag("-h","--help")}Print this screen

#{title("Year Directory")}
- Initialise a year directory to use aoc-cli.
- If no alias is passed, the default key is used

#{flag("-y","--init-year")}Initialise directory and fetch calendar
#{flag("-u","--user")}Specify alias for initialisation
#{flag("-d","--init-day")}Create day subdirectory, fetch puzzle and input
#{flag("-r", "--refresh")}Refresh calendar
 
#{title("Day Subdirectory")}
- These commands can be run from the day subdirectory

#{flag("-s","--solve")}Attempt puzzle
#{flag("-p","--part")}Specify part (attempts)
#{flag("-r","--refresh")}Refresh puzzle

#{title("Reddit")}
- Defaults to a Reddit CLI if one is installed

#{flag("-R","--reddit")}Open Reddit solution megathread
#{flag("-B","--browser")}Open Reddit thread in browser 

#{title("Manual Usage")}
- AocCli uses metadata so that these flags do not need to be entered.
- Command flags can be entered manually, but this is not recommended

#{flag("-u","--user")}Specify user
#{flag("-Y","--year")}Specify year
#{flag("-D","--day")}Specify day
#{flag("-p","--part")}Specify part
 
#{title("Configuration")}
- Pass with a value to update setting
- Pass without an argument to display current setting. 

#{flag("-U","--default")}Default key alias to use 
#{flag("-G","--gen-config")}Creates an example config file

#{title("Tables")}
- Print stats in a terminal-friendly table

#{flag("-a","--attempts")}Prints previous attempts for puzzle (part needed)
#{flag("-c","--simple-cal")}Prints your progress
#{flag("-C","--fancy-cal")}Prints your calendar file
#{flag("-S","--stats")}Prints your stats (time taken, number of attempts)

help
system("echo '#{help}' | less -r")
