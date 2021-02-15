puts <<~help
Advent of Code - cli, Feb 2021: version 0.1.0

#{title("Usage")}
#{"    aoc".bold + " -flag".italic.yellow + " value".bold.blue}

#{title("Setup")}
- Store session cookie keys to access AoC
#{flag("-k", "--key")}Store a session cookie to use the cli.
#{flag("-u", "--user")}Set alias for key (default: "main")

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
#{flag("-r","--refresh")}Refresh puzzle
#{flag("-a","--attempts")}Prints previous attempt table
#{flag("-p","--part")}Specify part (attempts)
#{flag("-R","--reddit")}Open Reddit solution megathread
#{flag("-b","--browser")}Open Reddit thread in browser 

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
#{flag("-B","--browser")}Always open Reddit in browser (default: false)
#{flag("-U","--default")}Default key alias to use (default: "main")
help
