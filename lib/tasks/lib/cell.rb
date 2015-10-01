# require "./lib/tasks/lib_require.rb"

class Cell 
	def initialize
		@children = []
	end
	
	attr_accessor :children
	
	def dump
	end
	
end

########################################################################
########################################################################
class FileCellBase < Cell
	# TYPE_UNKOWN = 0
	# TYPE_DIR    = 1
	def initialize( full_name )
		@full_name = full_name
		super()
	end
	
	attr_accessor :full_name
	
	def data
	end
	
	def to_s
		summary
	end
	
	def summary
		"#{@full_name}"
	end
	
	def dump
		puts summary
	end
end

########################################################################
class DirectoryCell < FileCellBase
	
	def initialize( dir_name )
		# @dir_name = dir_name
		# @children = []
		super
	end
	
	# attr_accessor :children
	attr_accessor :dir_name
	
	def data
		@dir_name
	end
	
	def to_s
		@dir_name
	end
	
	def summary
		"Directory: #{super}"
	end
	
	def dump
		puts summary
	end
end

########################################################################
class FileCell < FileCellBase
	
	def initialize( file_name )
		# @file_name = file_name
		# @children = []
		super
	end
	
	# attr_accessor :children
	attr_accessor :file_name
	
	def data
		@file_name
	end
	
	def to_s
		@file_name
	end
	
	def summary
		"File: #{super.split('/').last}"
	end
	
	def bare_file_name
		full_name.split('/').last
	end
	
	def has_extension?( extension )
		@filename.end_with?( extension )
	end
	
	def dump
		super
		puts summary
	end
end

########################################################################
class SpecialFileCell < FileCell
	def initialize( file_name, type )
		super( file_name )
		@type = type
	end
	
	attr_accessor :type

	def to_s
		super
	end
	
	def summary
		"#{@type}: #{super}"
	end
	
	def dump
		puts summary
	end
end
