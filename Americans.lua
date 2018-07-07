--[[

	Americans
		A program for counting the frequency of adjacent letters in every word of a dictionary
		
	Processing an English dictionary of 370k words takes >3 seconds on an i7-7500U @ 2.70GHz (hmm...)
		
	Usage:
	lua Americans.lua [filename] [-v]
	
	[filename]: Text document, a dictionary with words separated by newlines
	      [-v]: Verbose mode, shows non-essential print information
	
	Americans.lua is licensed under the MIT License

	Copyright (c) 2018 Sick Gilmartin

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
	
	"Why do Americans think everybody speaks English?"
		  
]]--

-- Arguments
FILENAME = arg[1]
VERBOSE  = arg[2] == "-v"

-- Ascii constants
UPPERCASE = 64
LOWERCASE = 96

force_print = print

-- Wrapper for print to skip all non-essential print info, use force_print instead
function print(...)
	if VERBOSE then
		force_print(...)
	end
end

-- Failsafe for some potential script errors
function help()
	force_print("Invalid parameters!")
	force_print("Example usage: lua Americans.lua [filename] [-v]")
end

-- Create dictionary and total letter count arrays
function setup_database()
	d = {} -- Dictionary
	t = {} -- Letter totals

	local i, j
	for i = 1, 26 do
		d[i] = {}
		t[i] = {0}
		
		for j = 1, 26 do
			d[i][j] = {0}
		end
	end
end

-- Format collected data
function print_database()
	local i, j, str, header, totals
	
	header = ""
	totals = ""
	for i = 1, 26 do
		header = string.format("%s%7s", header, string.char(i + UPPERCASE))
		totals = string.format("%s%7s", totals, t[i][1])
	end
	force_print("\nLetter totals:")
	force_print(" " .. totals .. "\n")
	force_print(" " .. header)
	
	for i = 1, 26 do
		str = ""
		
		for j = 1, 26 do
			str = string.format("%s%7s", str, d[i][j][1])
		end
		force_print(string.char(i + UPPERCASE) .. str)
	end
end

function export_database()
	export = io.open("previous_dictionary.usa", "w")
	
	local i, j
	
	-- Write totals
	for i = 1, 26 do
		export:write(t[i][1].."\n")
	end
	
	-- Write totals for individual letters
	for i = 1, 26 do
		
		for j = 1, 26 do
			export:write(d[i][j][1].."\n")
		end
		
	end
	
	io.close(export)
end

function import()
	local line_count = 0
	file = io.open(FILENAME, "r")
	
	if not file then
		help() -- Show help on invalid file
	else
	
		for line in io.lines(FILENAME) do
		
			line_count = line_count + 1
			
			-- Optional progress bar
			if line_count % 1000 == 0 then
				print("Processing... line " .. line_count)
			end
			
			local i
			for i = 1, string.len(line) do
			
				line = string.lower(line)
			
				-- Spilt word into two letter substrings
				local first, second
				first = string.sub(line, i, i)
				second = string.sub(line, i+1, i+1)
				
				local fv, sv
				fv = string.byte(first) - LOWERCASE
				
				-- If char is in range
				if ((fv > 0) and (fv <= 26)) then
					t[fv][1] = t[fv][1] + 1
					
					-- Record letter if the string is a pair and not a single letter
					if (second ~= "") then
					
						sv = string.byte(second) - LOWERCASE
						if ((sv > 0) and (sv <= 26)) then -- If char is in range
							d[fv][sv][1] = d[fv][sv][1] + 1
						end
						
					end
				end
				
			end
		end
		
		io.close(file)
	
	end
	
end

function main()
	if not arg[1] then
		help()
	else
		setup_database()
		import()
		print_database()
		export_database()
	end
end

main()