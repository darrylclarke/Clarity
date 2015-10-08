# require "/Users/darrylclarke/prj/clarity/lib/tasks/lib/file_reader.rb"
require "/Users/darrylclarke/prj/clarity/lib/tasks/lib/tools.rb"
module CodeMethodsHelper
	
	def get_code_for_method( method )
		f = FileReader.new
		if method.code_file.name =~ /\.h\z/
			lines = f.get_range_in_file( method.code_file.path, method.impl_start, method.impl_end )
		else	
			start_pos = method.signature_line || method.impl_start
			
			lines = f.get_range_in_file( method.code_file.path, start_pos, method.impl_end+1 )
		end
		output = String.new
		# NEWLINE = "\r\n"
		lines.each do |line|
			output += "#{line.line.r_just}#{line.text}\r\n"
		end
		output
	end
end
