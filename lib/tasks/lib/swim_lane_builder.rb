class SwimLaneCollection
	def initialize( directory_tree_builder )
		@directory_tree_builder = directory_tree_builder
		@all_rows = []
		@widest = @first = @last = 0
		@total_width = 0
	end
	
	attr_accessor :directory_tree_builder, :all_rows, :widest, :total_width
	
	def build 
		lane_builder = SwimLaneBuilder.new
		
		@first = 0
		@last = @directory_tree_builder.count_by_level.size - 1
		@widest = @directory_tree_builder.widest_level
		
		if( @widest == 0 || @first == @last )
			@all_rows[0] = lane_builder.build_simple_row( @directory_tree_builder.levels[0] )
		else
			@all_rows[ @widest - 1 ] = lane_builder.build_row_above_widest_row( 
											@directory_tree_builder.levels[ @widest - 1])
			
			@all_rows[ @widest     ] = lane_builder.build_widest_row_based_on_row_above(
				  							@all_rows[ @widest-1 ],
											@directory_tree_builder.levels[ @widest ] );
			# build rows above
			i = @widest - 2
			while( i >= @first )
				@all_rows[ i ] = lane_builder.build_simple_row( @directory_tree_builder.levels[i] )
				i -= 1
			end
			
			# build rows below
			i = @widest + 1
			while( i <= @last )
				@all_rows[ i ] = lane_builder.build_simple_row( @directory_tree_builder.levels[i] )
				i += 1
			end
		end
		@all_rows			
	end
	
	def assign_x_axis
		assign_x_axis_widest_row
		assign_x_axis_row_above_widest
		calculate_x_axis_for_other_rows
	end
	
	def setup_links
		i = 1 
		while( i <= @last )
			navigator = SwimLaneNavigator.new( @all_rows[i]   )
			
			@all_rows[i-1].each_with_index do |swim_lane, lane_index|
				links_for_lane = []
				swim_lane.dir_cell.each_with_index do |cell, cell_index|
					links_for_cell = []
					
					if !( cell === :nil_column )
						cell.children.each do |child|
							spot = navigator.find( child )
							if spot.valid?
								spot.row = i
								links_for_cell << spot
							end
						end
					end
					links_for_lane << links_for_cell
				end
				swim_lane.links = links_for_lane
			end
			i += 1
		end
	end

private

	def assign_x_axis_widest_row
		x = 0
		navigator = SwimLaneNavigator.new( @all_rows[ @widest ])
		
		navigator.iterate_cell do |lane, lane_idx, cell, cell_idx|
			width = lane.default_cell_width	
			lane.set_x_pos_for_cell( cell_idx, x )
			lane.width += width
			x += width
		end
	end
	
	def assign_x_axis_row_above_widest
		x = 0
		@all_rows[ @widest-1 ].each_with_index do |lane_n_minus_1, index|
			lane_n = @all_rows[ @widest ][ index ]
			width  = lane_n.width
			center = lane_n.get_center
			 
			lane_n_minus_1.set_x_pos_for_cell(0, x + (width / 2) - (lane_n.default_cell_width/2) )
			lane_n_minus_1.width = width
			
			x += width
		end
		@total_width = x
	end
	
	def calculate_x_axis_for_other_rows
		# build rows above
		i = @widest - 2
		while( i >= @first )
			assign_x_axis_for_autospread_row( i )
			i -= 1
		end
		
		# build rows below
		i = @widest + 1
		while( i <= @last )
			assign_x_axis_for_autospread_row( i )
			i += 1
		end
	end
	
	def assign_x_axis_for_autospread_row( i )
		num_segments = @all_rows[i].count + 1
		segment_width = @total_width / num_segments
		
		@all_rows[i].each_with_index do |lane, index|
			lane.x_pos[0] = segment_width + index * segment_width
			lane.width = segment_width
		end	
	end
end

class SwimLaneNavigator # iterate_row
	def initialize( row )
		@row = row
	end

	def iterate_cell
		@row.each_with_index do |swim_lane, lane_index|
			swim_lane.dir_cell.each_with_index do |cell, cell_index|
				yield swim_lane, lane_index, cell, cell_index
			end
		end
	end
	
	def iterate_lane
		@row.each_with_index do |swim_lane, lane_index|
			yield swim_lane, lane_index
		end
	end
	
	def find( cell_to_search_for )
		iterate_cell do  |lane, lane_idx, cell, cell_idx|
			if cell === cell_to_search_for
				return SwimLaneLink.new( nil, lane_idx, cell_idx)
			end
		end
		SwimLaneLink.new(nil, nil, nil)
	end
	
	def find_by_link( link )
		@row[link.lane].display_boxes[ link.cell ].display_id
	end
	
	def lane( n )
		@row[n]
	end
end

class SwimlanePrinter
	def initialize( input )
		@all_rows = input.all_rows
	end
	
	def pprint
		stop = true
		@all_rows.each_with_index do |row, i|
			puts("***** Row: #{i}")
			row.each do |lane|
				print lane.mode.to_s + " [" + 
					lane.dir_cell.map{ |c| c.name+"[#{c.parent && c.parent.name}]" }.join(", ") + 
					"] w=#{lane.width}\n"
				print lane.mode.to_s + " [" + 
					lane.links.map{ |l| l.map {|q| q.to_s}.join(",") }.join(":    ") + "]\n"					
			end
			puts
		end
	end
end
				

class SwimLaneBuilder

	def initialize
	end
		
	def build_simple_row( data )
		lanes = []
		data.each do |cell|
			new_lane = SwimLane.new( :autospread )
			new_lane.add( cell )
			lanes << new_lane
		end
		lanes
	end
	
	def build_row_above_widest_row( data )
		num_lanes = data.count
		
		lanes = []
		i = 0
		num_lanes.times do
			new_lane = SwimLane.new( :center )
			new_lane.add( data[i] )
			lanes << new_lane
			i += 1
		end
		lanes
	end
	
	def build_widest_row_based_on_row_above( row_above, data )	
		lanes = []
		i = 0
		row_above.each do |lane|
			new_lane = SwimLane.new( :hstack )
			parent_cell = row_above[i].dir_cell[0]
			
			parent_cell.children.each do |child|
				next unless child.is_a? DirectoryCell
				new_lane.add( child )
			end
			
			# need somthing there
			new_lane.add( :nil_column ) if new_lane.dir_cell.count == 0
			
			lanes << new_lane
			i += 1	
		end
		lanes
	end		
end

