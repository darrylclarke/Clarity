module CodeFilesHelper
	def get_code_for_file( file )
		f = FileReader.new
		lines = f.get_range_in_file( file.path ) #takes advantage of default arguments to get the entire file.
		
		output = String.new
		# NEWLINE = "\r\n"
		lines.each do |line|
			output += "#{line.line.r_just}#{line.text}\r\n"
		end
		output
	end
end
