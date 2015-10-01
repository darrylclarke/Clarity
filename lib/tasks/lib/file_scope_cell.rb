# require "./lib/tasks/lib_require.rb"

class FileScopeCell < Cell
	def initialize( name = "", line = nil )
		super()
		@text_lines = []
		@body_lines = []
		@line       = line
		@name       = name
	end
	
	attr_accessor :text_lines, :body_lines, :line, :name

	def add_child( c )
	byebug if !c
		@children << c
		c
	end

	def add_line( l )
		@text_lines << l
		l
	end
	
	def add_body_line( l )
		@body_lines << l
		l
	end

	def text
		@name
	end
	
	def self.dump( cell, level = 0 )
		tab = "          "
		cell.children.each do |c|
			#l_text = c.text_lines.map() {|x| x.text }.join(" @ ");
			# l_text = "" 
			# c.text_lines.each { |x| l_text += "[#{x.line}] #{x.text} @ " }
			# l_text.chop!()
			# l_text.chop!().strip()
			# l_text = ""
			# byebug if c.line == 131
			puts "^^^^^^^^^^^^^^^^^^^^^^ ERROR no c ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^" if !c
			puts "#{c.line.r_just}#{tab*level}#{c.name} [[#{c.class}]] ==> #{c.namespace}, #{c.scope}" if c
			#byebug if c.text.index( "void method()") == 0	
			if c.body_lines.any?
				c.body_lines.each { |x| puts "#{c.line.r_just}#{tab*level}\t @ #{x.line}] #{x.text}" }
			end
			
			FileScopeCell.dump(c, level+1 )
		end
	end
	
	#
	# Find a sub-cell with matching text.  For debugging and unit tests
	#
	def self.find( cell, text )
		return cell if cell.name == text
		cell.children.each do |c|
			ret_val = FileScopeCell.find(c, text )
			return ret_val if ret_val
		end
		return nil		
	end
end


class CodeElementCell < FileScopeCell
	def initialize( name = "", line = nil )
		super
		@scope     = :global
		@namespace = ""
		@const     = false
		@static    = false
		@type      = nil
	end
	attr_accessor :scope, :namespace, :const, :static, :type
end

class VariableCell < CodeElementCell
	def initialize( type_in, name, line = nil )
		super( name, line )
		self.type = type_in
	end
	
	def text
		"#{@type} #{@name}"
	end
end

class MethodCell < CodeElementCell
	def initialize( type_in, name, args, line = nil )
		super( name, line)
		@doing_const     = false
		@class_name      = nil
		@impl_file       = nil
		@impl_start_line = nil
		@impl_end_line   = nil
		@abstract        = nil
		self.type, @args = type_in, args
	end
	attr_accessor :doing_const, :class_name, :impl_file, :impl_start_line, :impl_end_line, :abstract, :args 
	
	def text
		"#{@type} #{@name}#{@args}"
	end
	
	def has_impl?
		body_lines.any?
	end
	
	def add_body_line( l )
		super
		
		if @impl_start_line == nil || @impl_start_line > l.line
			@impl_start_line = l.line
		end
		
		if @impl_end_line == nil || @impl_end_line < l.line
			@impl_end_line = l.line
		end
		l
	end
end

class ClassCell < CodeElementCell
	def initialize( name = "", line = nil)
		super
		@methods = []
		@variables = []
		@ancestors = nil
	end
	
	attr_accessor :methods, :variables, :ancestors
end
