# require "./lib/tasks/lib_require.rb"

########################################################################
require "open3"

class FileCellFactory
	def self.reset
		@@count = 0
	end
	def self.get_count
		@@count
	end
	#
	# Main factory method
	#
	def self.create( fragment_name, file_name )
		if File.ftype( file_name ) == 'directory'
			puts ">> directory #{file_name}" if DEBUG&&false
			return DirectoryCell.new( file_name ) if fragment_name[0] != '.'
			return nil
		elsif File.executable?( file_name )
			return SpecialFileCell.new( file_name, "executable" )
		end

		file_type, status = Open3.capture2e("file", file_name)
		
		if status.success? 
			if file_type.include?("text")
				
				if file_name[0] == "."
					return SpecialFileCell.new( file_name, "hidden" )
				end
				["md", "rdoc", "html"].each do |special_extension|
					if file_name.end_with? ".#{special_extension}" 
						return SpecialFileCell.new( file_name, special_extension )
					end
				end
				
				#if file_name.end_with?( ".h" ) || file_name.end_with?( ".cc" )
					@@count += 1
					return FileCell.new( file_name )
				#else
				#	return SpecialFileCell.new( file_name, file_name )
				#end
			elsif file_type.include?("pdf")
				return SpecialFileCell.new( file_name, "pdf" )
			end
		end
		return SpecialFileCell.new( file_name, "hidden" ) if file_name[0] == '.'
		return SpecialFileCell.new( file_name, "unknown" )
	end
				
private

	def self.text_file?(filename)
	file_type, status = Open3.capture2e("file", filename)
	status.success? && file_type.include?("text")
	end
	
end

########################################################################
class CellPrinter
	def self.output( cell )
		puts cell.to_s
		wait = gets.chomp if DEBUG
		
		@@h_files = true
		do_process cell
		
		@@h_files = false
		do_process cell

		do_print cell, 0
	end
	
private
	
	def self.do_process( cell )
		if cell.instance_of? FileCell
			if( @@h_files )
				return if cell.summary.index(".h") == nil
			else
				return if cell.summary.index(".cc") == nil
			end
		end
		
		print cell.summary, " ", cell.class, ", ", cell.children, "\n" if VERBOSE
		print cell.summary, "\n" if !VERBOSE
		
		if cell.instance_of? FileCell
			fr = FileReader.new;
			#byebug
			
			lines = fr.load( File.open( cell.full_name, "r" ), :debug )
			f = FileParser.new( "", lines )
			cell.children << f.process
			cell.num_lines = fr.highest_line_number
			#FileScopeCell.dump( cell.children[0] )
			return
		end
		
		return if cell.children.count == 0
			
		cell.children.each do |child|
			do_process( child )	 
		end
	end
	
	
	def self.do_print( cell, indent_level )

		puts "********************************************************************************"
		puts "********************************************************************************"
		puts "********************************************************************************"
		print "\t"*indent_level
		print cell.summary, " ", cell.class, ", ", cell.children, "\n" if VERBOSE
		print cell.summary, "\n" if !VERBOSE
				
		wait = gets.chomp if DEBUG
		
		if cell.instance_of? FileScopeCell
			FileScopeCell.dump( cell )
			return
		end	
		
		cell.children.each do |child|
			FileScopeCell.dump( child ) if child.instance_of? FileScopeCell
			do_print( child, indent_level + 1 ) if child.class < FileCellBase	
		end
	end
end


		
			
		

	
