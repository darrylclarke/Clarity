# require "./lib/tasks/lib_require.rb"

class CppClassParser
	def initialize( cell )
		@file_scope_cell = cell
	end
	
	def start
		@scope = :private
		base_cell = ClassCell.new( @file_scope_cell.text[5..-1].strip() )	
		
		@file_scope_cell.body_lines.each do |l|
			if l.index "public:" == 0
				@scope = :public
				next
			elsif l.index "protected:" == 0
			 	@scope = :protected
				 next
			elsif l.index "private:" == 0
			 	@scope = :private
				 next
				 
			elsif l.index "#" == 0
				next
			end
			
			pos     = l.find  METHOD_CALL_REGEX
			pattern = l.match METHOD_CALL_REGEX
			if pos && pos > 0
				# This is a method
				
				base_cell.methods << CodeElementCell.new( pattern )
				
				if l.find(';')
					# No implementation	
					next
				else
					# has implementation
				
				 				 