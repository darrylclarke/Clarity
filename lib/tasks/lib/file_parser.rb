# require "./lib/tasks/lib_require.rb"

class CppParser
	def initialize
	end
	
	def self.is_preprocessor?( fifo )
		fifo.data[0].text.index("#") == 0
	end
	
	def self.get_namespace( fifo )
		m = fifo.data[0].text.match /namespace\s*[_0-9a-zA-Z]*\s*/
		return false if !m
		m[0].split(' ')[1]
	end
	
	def self.get_structure( input )
		if input.is_a? Fifo
			str = input.before.text
		else
			str = input.to_s
		end
		m = str.match /class\s*|struct\s*|union\s*/
		return false if !m
		
		return false if str.match /^enum class/  # These aren't class definitions either
		return false if get_class_forward_definition( str )
		
		structure_type = nil
		class_name = nil
		ancestors = nil
		
# 2.2.1 :022 > s2 = "template <typename class T_parser8a>  class object_ref : public skdkdl, kskdk : call(2) : call(3) :call(4)"
# "template <typename class T_parser8a>  class object_ref : public skdkdl, kskdk : call(2) : call(3) :call(4)"
# 2.2.1 :023 > s2.split  /\s*:\s*/
# [
#     [0] "template <typename class T_parser8a>  class object_ref",
#     [1] "public skdkdl, kskdk",
#     [2] "call(2)",
#     [3] "call(3)",
#     [4] "call(4)"
# ]
		if str[-1] == '{'
			str.chop!
			str.strip!
		end
		
		return false if str[-1] == ')' # Class definitions never end with ')', method signatures do.
		
		str.gsub! "::", "@@"
		
		by_colon = str.split /\s*:\s*/
		
		if by_colon.length >= 1 
			pos = by_colon[0].rindex /\s/ # Find last whitespace.  This is where 'class object_ref' is

			class_name = "" if !pos
			class_name = by_colon[0][pos+1..-1] if pos
			
			by_template_char = by_colon[0].split( '>' )
			test = by_template_char[-1]
			m3 = test.match( /class\s*|struct\s*|union\s*/ )
			if( !m3 )
				return false;
			end
			structure_type = m3[0].strip
		end
		
		if by_colon.length >= 2
			ancestors = by_colon[1]		
		end
		
		 
		structure_type.gsub!( "@@", "::" ) if structure_type
		ancestors.gsub!( "@@", "::" ) if ancestors
		
		return [structure_type, class_name, ancestors]
	end
	
	def self.get_assign_struct_to( fifo )
		m = fifo.before.match /\=\s*\{/
		return false if !m
		true
	end
	
	# Sometimes, in c++ a forward declaration of a class is made
	
	def self.get_class_forward_definition( str )
		str =~ /^class\s*[_0-9a-zA-Z]*\s*\;/
	end
	
	# This is only called with things that don't belong in a method.  It is designed to deal with all of tthe
	# crazy suffixes that CPP puts on methods, like:
	#   void xyz( int a = 5 ) = 0;
	#   void xyz( int a = 5 ) const;
	#   void xyz( int a = 5 ) = default;
	#   void xyz( int a = 5 ) override;
	#	void xyz( int a = 5 ) override = default;
	# The common thread is they all happen with methods and they all happen after the ().
	def self.prune_string_remove_unnecessary_stuff( str )
	
	
		# byebug if str =~ /abczed/
	
		pos_bracket = str.rindex(')')
		return( {string: str} ) if !pos_bracket
		
		output = {}
		text_of_interest = str[pos_bracket..-1]
		
		output[:is_abstract] = true if text_of_interest =~ /=\s*0/
		output[:doing_const] = true if text_of_interest =~ /const/
		output[:string]      = str[0..pos_bracket] + (text_of_interest[-1] == ';' ? ';' : ' {')
			
		return output
	end
	
	def self.get_method_implementation( str )
	# byebug
		m = str.match /[_0-9a-zA-Z\:\<\>\,]*\s*\(.*\)\s*\{/
		return false if !m
		
		on_brackets = str.split('(')
		
		on_brackets[0].strip!
		pos = on_brackets[0].rindex(' ')
		pos = 0 if !pos
		method_name = on_brackets[0][pos..-1].strip
		if ['do', 'while', 'if', 'for', 'switch'].include?( method_name )
			return false;
		end
		
		return_type = on_brackets[0][0...pos].strip
		
		m = ('(' + on_brackets[1]).match /\(.*\)/
		return false if !m
		arguments = m[0] #no strip needed due to regex
		
		[return_type, method_name, arguments]	
	end
	
	def self.get_method_signature( str )
		# the main match
		m = str.match /[_0-9a-zA-Z\:\<\>\,]*\s*\(.*\)\s*\;/
		return false if !m
		
		method_name = m[0].split('(')[0].strip
		method_name_pos = str.index( method_name )
		
		return_type = str[0...method_name_pos].strip
		
		m = str.match /\(.*\)/
		arguments = m[0]
		
		if ['do', 'while', 'if', 'for', 'switch'].include?( method_name)
			return false;
		end
		
		[return_type, method_name, arguments]	
	end

	# this is intended to find the public: private: protected: labels in C++ code
	def self.get_scope( fifo )
		str = fifo.data[0].text
		return :public    if str.index("public:")    == 0 
		return :protected if str.index("protected:") == 0 
		return :private   if str.index("private:")   == 0 
		false
	end
	
	def self.is_const_var?( text )
		(text =~ /^const\s*.*\;/) && (text !~ /\(.*\)/)
	end
		
	def self.is_method_returning_const?( text )
		(text =~ /^const\s*.*/) && (text =~ /\(.*\)/)
	end
	
	def self.is_method_doing_const?( text )
		text =~ /const\s*\(/
	end
	
	def self.get_variable_name( text )
		match = text.match /[_0-9a-zA-Z]*\s*[\=\;]/
		match[0].chop.strip
	end
	
	def self.get_variable_type( text )
		name = get_variable_name( text )
		text[0...text.index(name)].strip
	end
	
	def self.is_destructor?( cell )
		cell.type.index('~')
	end
	
	def self.fix_destructor( cell )
		cell.type.chop! # remove ~
		cell.type.strip!
		cell.name = "~" + cell.name
	end
	
	def self.is_method_forward_decl?( text )
		pos_equals      = text.index('=') || text.length;
		pos_brackets    = text.index('(') || text.length;
		is_assignment = false
		if( pos_equals < pos_brackets )
			is_assignment = true
		end
		(text =~ /\(.*\)/) && (text[-1] == ';') && !is_assignment && !is_typedef?( text )
	end
	
	def self.is_variable_declaration?( text )
		(text =~ /[_0-9a-zA-Z]*[;|=]/) && (text !~ /\(.*\)/)
	end
	
	def self.get_class_name( str )
		# index_double_colon_first = str.index("::")
		# index_first_open_parenthesis = str.index("(");
		# if index_double_colon_first == nil || index_first_open_parenthesis == nil || index_first_open_parenthesis < index_double_colon_first
		# 	# could have void MyClass::MyMethod( NAMESPACE::type var )
		# 	return nil
		# end
		
		two_halves = str.split("::")
		if two_halves.length == 2
			class_name = two_halves[0]
			method_name = two_halves[1]
		elsif two_halves.length == 1 
			method_name = str
			class_name = nil
		end
		return [class_name, method_name]
	end
	
	# def self.is_pure_virtual?( str )
	# 	str =~ /\)\s*=\s*0\s*\;/
	# end
	
	def self.is_typedef?(str)
		str =~ /^typedef/
	end
	
end

	
class NamespaceTracker
	def initialize
		@stack = []
	end
	
	def push( str )
		@stack << str
	end
	
	def pop 
		@stack.pop
	end
	
	def to_s
		return @stack.join("::")
	end
end

class BigList
	def initialize
		@@list = []
	end
	
	def self.add( l )
		@@list << l 
	end
	
	def self.dump
		@@list.each {|x| x.dump }
	end
end

class FileParser
	
	def initialize( file_name, lines )
		@file_name, @lines = file_name, lines
		@line_num = 0
		@ltp = nil
		@base_cell = FileScopeCell.new
		@structure = nil
		@fifo = Fifo.new
		@brackets = []
		@namespace = NamespaceTracker.new
		@current_scope = :public
	end
	
	attr_accessor :brackets, :fifo
	
	def brace_count
		@brackets.length
	end
		
	def make_scope( name, text, data )
		{ name: name, text: text, data: data }
	end
	
	def first_available_container( bracket_array )
		i = bracket_array.length - 1
		while i >= 0 
			return bracket_array[i][:data] if bracket_array[i][:data]
			i -= 1
		end
		return nil
	end
	
	def add_line_with_semicolon_to_parent( str, line, parent, fields_and_data )
		child = nil
		if( CppParser.is_method_forward_decl?( line.text ) )
			# Handle method signatures
			
			# # is it abstract?
			# is_abstract = CppParser.is_pure_virtual?( str )
			
			text_array = CppParser.get_method_signature( str )
			# byebug if !text_array
			# return nil if !text_array
			# if !text_array	
			# 	BigList.add line
			# 	child = CodeElementCell.new
			# else
			
			class_and_method_names_array = CppParser.get_class_name( text_array[1] )
			child = MethodCell.new( text_array[0], class_and_method_names_array[1], text_array[2], @fifo.data[0].line )
			child.namespace  = @namespace.to_s
			child.scope      = @current_scope
			child.class_name = class_and_method_names_array[0]  # which could be nil, that's ok
			child.abstract   = fields_and_data[:is_abstract]    # which could be nil, that's ok
			CppParser.fix_destructor(child) if CppParser.is_destructor?( child )
			# end
			
		# elsif CppParser.get_class_forward_definition( str )

		else
			child = VariableCell.new(CppParser.get_variable_type(str), CppParser.get_variable_name(str), line.line )
			child.namespace = @namespace.to_s
			child.const = true if CppParser.is_const_var?( line.text )
			child.add_body_line line
		end
		parent.add_child( child )
		return child
	end
		
	def process
		@fifo.load @lines
		@brackets.push make_scope( :file, nil, @base_cell )
		baseline_bracecount = @brackets.length
		while @fifo.get_next
		# byebug if @fifo.data[0].line == 85
			most_recent_parent = first_available_container( @brackets )
			
			# byebug if @fifo.data[0].text.index "dc__DC"
			
			if CppParser.is_preprocessor?( @fifo ) 
				@fifo.set_to_end
				line = @fifo.before
				@fifo.transform_to_after!				
				#line.dump
				
				child = CodeElementCell.new("PreProcessor",  line.line )
				most_recent_parent.add_child( child )
				child.add_body_line line				
				next
			end
			
			test_scope_statement = CppParser.get_scope( @fifo )
			if test_scope_statement
			# byebug
				@current_scope = test_scope_statement 
				@fifo.advance_to_end
				@fifo.transform_to_after!
				next
			end
			
			
			match = @fifo.find_multiple('{;}')
			
			# C++ has }; a lot
			if match && @fifo.match_character && @fifo.next_character == ';'
				@fifo.advance_character
			end
			
			line = @fifo.before
			if match
				case @fifo.match_character
				
					when ';'
						print "**; #{@brackets.length} ** " if @DEBUG
						
						if most_recent_parent.is_a? MethodCell || line.text =~ /^class.*\;/
							most_recent_parent.add_body_line( line )
							@fifo.transform_to_after!
							# Don't adjust baseline_bracecount here, we are inside a method
							next
						end

						fields_and_data = CppParser.prune_string_remove_unnecessary_stuff( line.text )	
						str = fields_and_data[:string]

						case @brackets[-1][:name]
						
							when :struct
							
								child = add_line_with_semicolon_to_parent( str, line,  most_recent_parent, fields_and_data )
								# byebug if !child
								child.scope     = @current_scope
								
							when :method
								most_recent_parent.add_body_line( line )
								
							#when :file
								
							else
								add_line_with_semicolon_to_parent( str, line, most_recent_parent, fields_and_data )
						end
								
					when '{'
						# byebug if @fifo.data[0].line == 130
						prev_brace_level = @brackets.length
						
						if most_recent_parent.is_a? MethodCell
							most_recent_parent.add_body_line( @fifo.before )
							@fifo.transform_to_after!
							@brackets.push make_scope( :general, nil, nil )
							next
						end
						
						# Handle namespace
						text = CppParser.get_namespace( @fifo )
						if text
							#byebug
							@brackets.push make_scope( :namespace, text, nil )

							@namespace.push text
						end
						
						# Handle class/struct/union
						text_array = CppParser.get_structure( @fifo )
						if text_array
							child = ClassCell.new( text_array[1], @fifo.data[0].line )
							child.type = text_array[0]
							child.ancestors = text_array[2]
							child.namespace = @namespace.to_s
							most_recent_parent.add_child( child )
							@brackets.push make_scope( :struct, text_array, child )

							
							if child.type == "class"
								@current_scope = :private
							else
								@current_scope = :public 
							end
						end
							
						# Handle assign structure to
						text = CppParser.get_assign_struct_to( @fifo )
						if text	
							#byebug
							@brackets.push make_scope( :assingment, nil, nil )
						end
						
						# Handle method implementations
						fields_and_data = CppParser.prune_string_remove_unnecessary_stuff( line.text )	
						str = fields_and_data[:string]
						
						text_array = CppParser.get_method_implementation( str )
						if text_array && @brackets.length == baseline_bracecount
							class_name = CppParser.get_class_name( text_array[1] )
							# byebug if class_name
							class_and_method_names_array = CppParser.get_class_name( text_array[1] )
							child = MethodCell.new( text_array[0], class_and_method_names_array[1], text_array[2], @fifo.data[0].line )
							child.namespace   = @namespace.to_s
							child.scope       = @current_scope
							child.class_name  = class_and_method_names_array[0] # which could be nil, that's ok
							child.doing_const = fields_and_data[:doing_const]
							CppParser.fix_destructor(child) if CppParser.is_destructor?( child )
							
							most_recent_parent.add_child( child )
							@brackets.push make_scope( :method, text_array, child )

						end
						
						after_brace_level = @brackets.length
						@brackets.push make_scope( :general, nil, nil ) if (after_brace_level == prev_brace_level)
						baseline_bracecount = @brackets.length
						print "**{ #{prev_brace_level+1} ** " if @DEBUG
					
					when '}'
						print "**} #{@brackets.length} ** " if @DEBUG
						
						if @brackets.length == 1
							line = @fifo.before
							@fifo.transform_to_after!
							next
						end
												
						scope = @brackets.pop 
						
						if most_recent_parent.is_a?( MethodCell ) && @brackets.length > baseline_bracecount
							# Don't adjust baseline_bracecount here, we are inside a method
						else				
							baseline_bracecount = @brackets.length
							# Sometimes an implementation is just {}, need to force something in there to hold 
							# the place.
							if( scope[:name] == :method )
								just_added = most_recent_parent 
								if just_added.is_a?( MethodCell ) && !just_added.has_impl?
									just_added.add_body_line(Line.new line.line, "")
								end
							end
							
							# if exiting a namespace need to reset it
							@namespace.pop if scope[:name] == :namespace
							
							# stuff outside of structs and classes is :global
							@current_scope = :global if scope[:name] == :struct

						end
						
				end
				line = @fifo.before
				@fifo.transform_to_after!
				
				#line.dump
			else
				@fifo.set_to_end
				#
			end

		end
		
		# puts "****************************************"
		# puts "Ending brace level = #{@brackets.length}."
		# puts "****************************************"
		return @base_cell
	end

private

end
