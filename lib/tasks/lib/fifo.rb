# require "./lib/tasks/lib_require.rb"

class Fifo 
	def initialize
		@data = []
		@line_pos = nil
		@match_pos = 0
		@match_character = nil
		@source_lines = nil
		@dirty = true
	end
	
	attr_accessor :data, :char_pos, :match_character
	
	def load( lines )
		@source_lines = lines
		@line_pos          = 0
	end
		
	def get_next
		return false  if @line_pos >= @source_lines.length
				
		#byebug if @data && @data[0] && @data[0].line == 511
		if @data && @data[-1] && @match_pos < @data[-1].text.length
			return true
		end
		
		
		push @source_lines[@line_pos]
		@line_pos += 1
		@match_pos = 0
		return true
	end
	
	def find_multiple( s )
		@match_character = nil
		@match_pos = nil
		
		return false if data[-1] == nil
		
		@match_pos = data[-1].text.length  # set to end
		
		match = data[-1].find_multiple( s )
		
		if match[0]
			@match_pos       = match[0]
			@match_character = match[1]
			return true
		end
		return false
	end
	
	def before
		line = data[0].line
		text = ""
		data.each_index do |i|
			text += (data[i].text + ' ') if i < (data.length-1)
			text += data[i].text[0..@match_pos] if i >= (data.length-1)
		end
		Line.new( line, text )
	end		
		
	def transform_to_after!
		line = @data[-1].line
		length_of_last = @data[-1].text.length
		text = ""
		text = @data[-1].text[ (@match_pos+1)..-1 ] if @match_pos < (length_of_last-1)
		@data = []
		@data << Line.new( line, text ) if text.length > 0
		@match_pos = 0
	end
	
	def set_to_end
		@match_pos = @data[-1].text.length
	end
	
	def next_character
		return '' if @match_pos >= @data[-1].text.length - 1
		@data[-1].text[ @match_pos + 1]
	end
	
	def advance_character
		@match_pos += 1
	end
	
	def advance_to_end
		@match_pos = @data[-1].text.length
	end
	
	def find( s )
		data.each_index do |i|
			# puts "*** #{i}, #{data[i].text}"
			match = data[i].find_multiple( s )
			if match[0]
				match << i
				return match
			end
		end
		nil
	end
	
	def match( s )
		data.each_index do |idx|
			p = data[idx].text.index( s )
			m = data[idx].text.match( s )
			return [p, m[0], idx] if p
		end
		[nil, nil, nil]
	end
	
	def simple_find_in_last( s )
		return nil if data.length == 0
		data[-1].text.index( s )
	end
	
	def reset
		@data = []
	end
	
	def push( x )
		data << x
	end
	
	def pop
		data.pop
	end
		
	def d( s= nil )
		dump( s )
	end
	
	def dump( s = nil )
		puts "Fifo - #{s}, @match_pos=#{@match_pos}, @match_character=#{@match_character}"
		data.each {|d| d.dump }
	end
	
	def last 
		return nil if data.length <= 0
		data[-1]
	end		

	def part_that_belongs_to_next( c )
		return nil if @data.length == 0
		pos = data[-1].find( c )
		first_part = data[-1].before!( pos )
		ret = data[-1]
		data[-1] = first_part
		ret
	end
	
	def self.factory( *args )
		x = 1
		fifo = Fifo.new
		
		args.each do |text|
			fifo.push Line.new( x, text )
			x += 1
		end
		
		fifo
	end
			
			
	
end
