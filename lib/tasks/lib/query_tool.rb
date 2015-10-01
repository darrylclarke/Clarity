# require "./lib/tasks/lib_require.rb"

class DetailsTreeTraverser
	def initialize
		@base_node = nil
	end
	
	attr_accessor :base_node
	
	def set_tree( base_node )
		@base_node = base_node
		reset
	end
	
	def reset
	end
	
	def start
		return nil if !base_node || !base_node.children
		process_file_node( @base_node )
		true
	end
	
	def do_file_action( cell )
	end
	
	def do_code_action( cell, file_name )
	end 
	
	def process_file_node( cell )
		do_file_action( cell )
		
		cell.children.each do |child|
		# byebug
			if (child.class < FileCellBase )
				process_file_node( child )      
			else
			# byebug
				process_code_node( child, cell.full_name )
			end
		end
	end
	
	def process_code_node( cell, file_name )
	# byebug
	    do_code_action( cell, file_name )
		
		cell.children.each do |child|
			process_code_node( child, file_name ) 
		end
	end
end

class DetailsFileFinder < DetailsTreeTraverser
	def initialize
		@count = 0
		@list = []
	end
	attr_accessor :count, :list
	
	def do_file_action( cell )
	# byebug
		if cell.class == FileCell
			puts "#{cell.summary}"
			@list << cell
		end
	end
	
	def pprint
		@list.sort! {|x,y| x.bare_file_name <=> y.bare_file_name }
		@list.each { |x| puts x.bare_file_name }
		puts "count = #{@list.count}."
	end
end

class DetailsClassFinder < DetailsTreeTraverser
	def initialize
		@count = 0
		@list = []
	end
	attr_accessor :count, :list
	
	def do_code_action( cell, file_name )
		if cell.is_a?( ClassCell ) && (cell.type == "class")
			# puts "#{cell.name}"
			@list << cell.name
			
			if cell.name == "Application"
				FileScopeCell.dump( cell, 0 )
			end
		end
	end
	
	def pprint
		@list.sort!
		@list.each { |x| puts x }
		puts "count = #{@list.count}."
	end
end

class DetailsMethodFinder < DetailsTreeTraverser
	def initialize
		@count = 0
		@list = []
	end
	attr_accessor :count, :list
	
	def do_code_action( cell, file_name )
		if cell.is_a?( MethodCell ) && (cell.class_name)
			# puts "#{cell.name}"
			@list << (cell.class_name + "::" + cell.name + "\t(" + cell.text)
			
			# if cell.name == "Application"
			# 	FileScopeCell.dump( cell, 0 )
			# end
		end
	end
	
	def pprint
		@list.sort!
		@list.each { |x| puts x }
		puts "count = #{@list.count}."
	end
end