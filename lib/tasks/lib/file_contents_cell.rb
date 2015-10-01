# require "./lib/tasks/lib_require.rb"

class FileContentsCell < Cell
	DEBUG = false	
	
	def initialize( name, line, fragment=nil )
		@name, @line, @fragment = name, line, fragment
		if @fragment == nil
			@fragment = @line.text
		end
		super()
	end
	
	attr_accessor :line
	attr_accessor :fragment
	attr_accessor :name
	
end