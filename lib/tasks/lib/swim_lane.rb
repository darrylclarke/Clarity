class SwimLane
	@@BORDER_WIDTH = 12
	@@CELL_WIDTH   = 40
	@@CELL_AND_TEXT_HEIGHT = 50
	
	def initialize( mode )
		@dir_cell = []
		@mode = mode   # posible nodes are :center, :autospread, and :hstack
		@x_pos = []
		@width = 0
		@links = []
		@display_boxes = []
	end
	
	attr_accessor :dir_cell, :mode, :x_pos, :width, :links, :display_boxes
	
	def to_s
		output = ""	
		@dir_cell.each_with_index do |cell, index|
			output += "(#{cell.name} #{x_pos[index]} #{@links[index]}"
		end
		output
	end
	
	def default_cell_width
		@@BORDER_WIDTH + @@CELL_WIDTH + @@BORDER_WIDTH
	end
	
	def add( child )
		@dir_cell << child
	end
	
	def cell( n )
		dir_cell[n]
	end
	
	def set_x_pos_for_cell( cell_index, x_pos )
		@x_pos[ cell_index ] = x_pos
	end
	
	def get_center
		x_pos[0] + (width/2)
	end
	
	def as_hash( row_num, display_idx, cell_index_in_lane)
		{
			text:                dir_cell[ cell_index_in_lane ].name,
			x_pos:               x_pos[ cell_index_in_lane ],
			y_pos:               row_num,
			height:              @@CELL_AND_TEXT_HEIGHT,
			width:               @@CELL_WIDTH,
			folder_id:           dir_cell[ cell_index_in_lane ].active_record_object.id,
			num_code_files:      dir_cell[ cell_index_in_lane ].num_code_files,
			display_id:          display_idx,
			num_lines:           dir_cell[ cell_index_in_lane ].active_record_object.num_lines,
			notes_flags:         0
		}
	end
    
	
    def store_display_box( cell_index_in_lane, active_record_object )
		@display_boxes[ cell_index_in_lane ] = active_record_object
	end
	
	def get_box_index( cell_index_in_lane )
		@display_boxes[ cell_index_in_lane ].display_id
	end
	
private
	
	def size_of_all_dir_cell
		width = 0
		@dir_cell.each { |child| width += child.width }
		width
	end
	
	# def get_x_pos_for_cell( n )
	# 	@x_pos + @@BORDER_WIDTH + n * @@CELL_WIDTH
	# end
	
end

class SwimLaneLink
	def initialize( row, lane, cell )
		@row, @lane, @cell = row, lane, cell
	end
	
	attr_accessor :row, :lane, :cell
	
	def valid?
		lane && cell
	end
	
	def to_s
		"(#{row},#{lane},#{cell})"
	end
end
