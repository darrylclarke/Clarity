FOLDER_BIGG = "/Users/darrylclarke/prj/source/xenia/src/xenia"
TABS = "     "
DEBUGzz = false

class GraphicalDirectoryTreeBuilder

	def initialize( base_cell )
		@base_cell = base_cell
		@max_levels = 0
		@levels = []
		@count_by_level = []
		@widest_level   = 0
	end

	attr_accessor :max_levels, :levels, :base_cell, :count_by_level, :widest_level

	def process

		# count the levels
		puts if DEBUGzz
		process_cell( @base_cell, 0 ) # calculates @max_levels
		puts if DEBUGzz
		puts "#{@max_levels+1} levels." if DEBUGzz

		# get everything by level
		@levels = []
		for x in 0..@max_levels
			result = get_all_at_level( x )
			@levels << result if result
			
		end
			# binding.pry

		# which level has the most?
		@count_by_level = get_level_counts
		puts @count_by_level.join(", ") if DEBUGzz
		@widest_level = get_widest_level
		puts "Widest = ##{@widest_level}" if DEBUGzz
	end

	private

	def get_level_counts
		@levels.map { |level| level.count }
	end

	def get_widest_level
		max = 0
		max_index = 0
		@count_by_level.each_index do |x|
			puts "if #{@count_by_level[x]} > #{max}"
			if @count_by_level[x] > max
				max = @count_by_level[x]
				max_index = x
			end
		end
		max_index
	end

	def get_all_at_level( level )
		return nil unless level < max_levels

		output_level(@base_cell, level)
	end

	def process_cell( cell, indent_level, target_level=nil)

		if target_level
			if cell.class == DirectoryCell && indent_level == target_level
				puts "#{cell.full_name}" if DEBUGzz
				@level_count +=1
				@level_members << cell
				# binding.pry if target_level == 4
			end
		else
			puts "#{TABS*indent_level}#{cell.full_name}" if cell.class == DirectoryCell if DEBUGzz
		end
		
		@max_levels = indent_level > @max_levels ? indent_level : @max_levels
		
		 if cell.is_a? DirectoryCell
			cell.children.each do |child|
				process_cell( child, indent_level + 1, target_level )
			end
		end
	end

	def output_level( cell, level )
		puts "*** level:  #{level}" if DEBUGzz
		@level_count = 0
		@level_members = []
		process_cell( cell, 0, level)
		puts
		@level_count
		@level_members
	end
end
