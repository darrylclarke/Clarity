# require "./lib/tasks/lib_require.rb"

class Line
	def initialize( line, text = nil )
		if line.is_a?( Line ) && text == nil
			@line, @text = line.line, line.text
		else
			@line, @text = line, text
		end
	end
	
	attr_accessor :line, :text
	
	def reset_text
		text = nil
	end
	
	def find( c )
		pos = text.index( c )
		return pos if pos && pos >= 0 && pos < text.length
		nil
	end
	
	def match( m )
		text.match m
	end
	
	def before!(x)
		line2 = Line.new( @line, @text[0..x].strip() )
		if (x+1) >= @text.length
			@text = nil
		else
			@text = @text[x+1..-1].strip()
		end		
		line2
	end
	
	def find_multiple( chars_string )
		chars = chars_string.each_char()
		min = [nil, nil]
		chars_string.each_char do |c|
			pos = @text.index c
			min[0] ||= pos
			if( pos && min[0] && pos <= min[0] )
				min[0] = pos
				min[1] = c
			end
		end
		min
	end
	
	def dump( s = nil )
		puts "Line - #{s} --> #{line.r_just} #{text}"
	end 
	
end

class FileReader

	def initialize
		@lines = []
		@highest_line_number = 0
	end
	
	attr_accessor :highest_line_number
	
	def load( data_source, debug = false )
		@data_source = data_source
		@highest_line_number = 0
		initial_load
		join_lines
		strip_strings_and_comments
		preproccesor
		#fragments = split_file_into_fragments
		# print_to_console if debug === :debug
		@lines
	end

	#default arguments will get the entire file
	def get_range_in_file( file_name, line_a=1, line_b=-1 )
		@data_source = File.open( file_name, "r" )
		initial_load_range( line_a, line_b )
	end
	
	def get_entire_file( file_name )
		@data_source = File.open( file_name, "r" )
		initial_load
	end
	
	def print_to_console
		@lines.each { |l| puts "#{l.line.r_just} |#{l.text}| (#{l.text.length})" }
	end

private
	
	def initial_load
		@lines = []
		line_number = 0
		f = @data_source
		f.each do |s|
			line_number += 1
			line = s.strip()
			if line.length > 0
				@lines << Line.new(line_number, line)
			end
		end
		f.close if f.is_a? File
		@highest_line_number = line_number
		@lines
	end
	
	# default arguments will get the whole file
	def initial_load_range( line_a=1, line_b=-1 )
		@lines = []
		line_number = 0
		f = @data_source
		f.each do |line|
			line_number += 1
			next unless line_number >= line_a
			@lines << Line.new(line_number, line.chomp )
			break if line_b != -1 && line_number >= line_b
		end
		f.close if f.is_a? File
		@lines
	end
	
	# Process the data in place to join lines ending in '\'
	# Some lines may be appended to the ones before them.  Their text will be set to nil.
	def join_lines
		output = []
		n = 0
		while n < @lines.length do
			cur_line = n 
			longer_line = String.new;
			
			if @lines[cur_line].text[-1] == '\\'
				longer_line = @lines[cur_line].text.chop()
				cur_line += 1
				longer_line += @lines[cur_line].text
				longer_line.chop!() if longer_line[-1] == '\\'
			end
			while @lines[cur_line].text[-1] == '\\'
				cur_line += 1
				longer_line += @lines[cur_line].text[0..-2]
			end
			
			# if there were joined lines
			if n < cur_line
				@lines[n].text = longer_line
				
				# catch up
				while n < cur_line
					n += 1
					@lines[n].text = nil
				end
			end
			n += 1
		end
	end
		
	def strip_strings_and_comments
		output = []
		in_comment = false
		pos = 0
		
		@lines.each do |line|
			next if !line.text
			
			# Set up variables
			p1 = -1 
			p2 = -1 
			
			# Get rid of embedded quotes
			line.text.gsub!( /\\\"/, "" )
			# Get rid of all ' ' characters
			line.text.gsub!( /\'.\'/, "''" )
			# Delete all strings, but save #include "kkk" strings
			line.text.gsub!( /\".*\"/, '""' ) if !(line.text =~ /\#include/).is_valid?
			# Get rid of all /* */ comments on one line 
			line.text.gsub!( /\/\*.*\*\/\s*/, "" )  
			# Get rid of tabs
			line.text.gsub!( /\t/, " " )
			# Collapse multipe whitespace
			line.text.strip!();
			
			## Debug stuff
			# puts "#{line.line} - #{line.text}" if DEBUG
			if line.line == 1
				line.text.each_char { |c| puts c.ord } if DEBUG
			end
			
			# look for // and /* */
			while pos < line.text.length
				if in_comment
					p2 = line.text =~ /\*\// # */
				else
					p1 = line.text =~ /\/\// # //
					p2 = line.text =~ /\/\*/ # /*
				end
				# puts if DEBUG
				# puts "#{line.line} - #{line.text} ==> p1=#{p1} p2=#{p2}" if DEBUG
				
				if in_comment && p2.is_valid?
					#print "a " if DEBUG
					# cut off beginning up to */
					line.text = line.text[ p2+2 .. -1 ].strip() # .. -1 includes last char
					pos = 0
					in_comment = false
					next
					
				elsif in_comment && !p2.is_valid?
				#print "b " if DEBUG
					# the whole line is wrapped in /* and */ on other lines
					line.text = nil
					break
					
				elsif !p1.is_valid? && !p2.is_valid?
				#print "c " if DEBUG
					# This line has no comments
					break
				
				elsif (p1.is_valid? && !p2.is_valid?) || (p1.is_valid? && p2.is_valid? && p1 < p2)
				#print "d " if DEBUG
					# This is a // comment
					# cut off end
					line.text = line.text[ 0 ... p1 ].strip() # not including the //
					break
				
				elsif p2.is_valid?
					# Found a /* on the line, need to save first part before the /*
					temp = line.text[0...p2].strip()
					
					# if !p1.is_valid?  
					# 	#print "e " if DEBUG
					# 	# have /* but no //
					# 	# There was no */ terminating the line, so the rest is a comment
					# 	line.text = temp.strip()
					# 	break
				
					# if p1.is_valid? && p2 < p1
					#print "f " if DEBUG
					p3 = line.text =~ /\*\// # */
					
					if !p3.is_valid?
						# There is no */, the rest of the line is a comment.
					#print " f1" if DEBUG
						# The next line starts with a comment too.
						line.text = temp
						in_comment = true
						break	
					else 
					#print " f2" if DEBUG
						if p3 > p2 && p3 < p1
							line.text = temp + line.text[p3+2 .. -1]
							pos = p2
							next
						end
					end
				
				
				else
					#print "This line is wierd: #{line.line} #{line.text}" if DEBUG
					pos += 1
				end
				# puts if DEBUG
			end
			output << line if line.text && line.text.length > 0
		end
		@lines = output
	end
	
	def preproccesor
		output = []
		in_if_zero = false
		last_in_if_zero = false
		depth = 0
		
		@lines.each do |line|
			next if !line.text
				
			if line.text.start_with?( '#if 0' )
				depth += 1 
				in_if_zero = true  
			elsif line.text.start_with?( '#if' )
				depth += 1 
			end
			
			in_if_zero = false if line.text.start_with?( '#else' ) && in_if_zero && depth == 1
				
			if line.text.start_with?( '#endif' )
				if in_if_zero && depth <= 1
					in_if_zero = false 
					depth = 0
				else
					depth -= 1 	
					depth = 0 if depth < 0 
					# TODO - throw an exception
				end
			end
			
			if last_in_if_zero
				# do nothing
			elsif !in_if_zero && line.text && line.text.length > 0
			    output << line
			end
			last_in_if_zero = in_if_zero
		end
		@lines = output
	end
	
	def split_file_into_fragments
		fragments = []
		
		temp_str = String.new
		cur_line = nil
		i = 0
		
		for i in 0...@lines.length
			line = @lines[i]
			# @lines.each do |line|
			pos = 0
			last_pos = 0
			# cur_line ||= line
			
			# Add in whatever was left over from last time
			string_to_search = temp_str + line.text
			
			while string_to_search.length > 0


				# --------------- save #include and #define lines --------------
				if string_to_search.start_with("#")
					fragments << FileContentsCell.new( "#", cur_line )
					cur_line = nil # reset it for next time
					break;
				end

				# ------------- Find out what is first --------------
				like_a_class = /class, union, struct/.match( string_to_search )
				enum         = /enum/.match( string_to_search )
				method       = /\w*\s*\(/.match( string_to_search )
				
				pos_enum         = enum && string_to_search.index( enum[0] ) 
				pos_like_a_class = like_a_class && string_to_search.index( like_a_class[0] )
				pos_semicolon    = string_to_search.index(';')
				pos_method       = method && string_to_search.index( method[0] )
												
				min = get_min( 4, pos_like_a_class, pos_enum, pos_semicolon, pos_method )
				
				case
					# -------- Nothing interesting is on the rest of this line --------
					when min == nil
						temp_str += string_to_search
						# keep cur_line as it is
						break
						
					# -------- This begins an enum declaration  --------
					when min == pos_enum
						cur_line = line
						if pos_semicolon && pos_semicolon > pos_enum
							# have the entire enum 
							fragments << FileContentsCell.new( "enum", cur_line, string_to_search[ 0..pos_semicolon ] )
							string_to_search = string_to_search[ pos_semicolon+1 .. -1 ]
							cur_line = nil
							next
						end
					# -------- This is a class / struct / union declaration  --------
					when min == pos_like_a_class
					
					# ----------- The semicolon is first --------------
					when min == pos_semicolon
						temp_str = string_to_search[last_pos .. pos] # includes ';'
						fragments << FileContentsCell.new( "variable", cur_line, temp_str )
						cur_line = nil  # Reset for next time
						string_to_search = string_to_search[ pos+1 .. -1]
						next
					
					# ----------- A method is first  --------------
					when min == pos_method
				end
						

				# --------------- Is there a keyword on the line? --------------
				
				
			end	
		end
		
		return fragments
	end
	
	def get_min( num_to_process, *args )
		min = nil
		for x in 0...num_to_process
			min = args[x] if args[x] && (min == nil || args[x] < min)
		end
		min
	end
end
