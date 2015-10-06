# require "./lib/tasks/lib_require.rb"

########################################################################
class DirCellTreeFactory
DEBUG = false
	def self.create( base_dir )
		
		Dir.chdir( base_dir )
		pwd = Dir.pwd
		puts "Start pwd #{pwd}" if DEBUG
		
		base_cell = DirectoryCell.new( pwd )
		print base_cell
		
		FileCellFactory::reset
		# byebug
		process( base_cell, pwd )
		
		print "Working with #{FileCellFactory::get_count} files.  Press Enter to continue..."
		# gets
		
		base_cell
	end
	
private
	
	def self.process( cell, dir_name )
		puts "processing #{dir_name}" if VERBOSE
		# Dir.chdir( dir_name )
		# puts "cd #{dir_name}"
		local_count = 0
		
		Dir.foreach( '.' ) do |fragment_name|
			full_name = dir_name + '/' + fragment_name
			puts "** #{full_name}" if VERBOSE
			gets if DEBUG
			c = FileCellFactory.create( fragment_name, full_name )
			if !c
				next  # Don't process things that aren't valid subdirectories or files
			end
			local_count += 1 if c.is_a? FileCell
			c.parent = cell
			cell.children << c
			
			if c.instance_of? DirectoryCell
				Dir.chdir( fragment_name )
				process( c, full_name )
				Dir.chdir("..");
			end
		end
		cell.num_code_files = local_count
	end
end	