# require "./lib/tasks/lib_require.rb"

class Cell 
	def initialize
		@children = []
		@parent = nil
	end
	
	attr_accessor :children, :parent
	
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
		@active_record_object = nil
		super()
	end
	
	attr_accessor :full_name, :active_record_object
	
	def data
	end
	
	def name 
		@full_name
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
		@num_code_files = 0
		super
	end
	
	# attr_accessor :children
	attr_accessor :dir_name, :num_code_files
	
	def data
		full_name
	end
	
	def to_s
		data
	end
	
	def name
		full_name.split('/')[-1]
	end
	
	def summary
		"Directory: #{super}"
	end
	
	def dump
		puts summary
	end
	
	def count_c_plus_plus
		count = 0
		children.each do |f|
			count += 1 if f.is_a? FileCell && (f.has_extension?(".cc")  || f.has_extension?(".h") )
		end
		@num_code_files = count
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
		name
	end

	def name
		full_name.split('/')[-1]
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
	
	def get_folder_name
		parent.name
	end
	
	def get_folder_full_path
		parent.full_name
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
