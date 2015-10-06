require "~/prj/clarity/lib/tasks/lib_require.rb"

namespace :source_transformer do

  # in the case of generate_campaigns: :environment
  # the task name will be generate_campaigns and the :environment option makes
  # it load the Rails environment for this task
CLEAN = false

def create_folders( input_cell, folders_cache, project )
   if input_cell.class == DirectoryCell
     input_cell.active_record_object = Folder.create( 
                          name: input_cell.name, 
                          path: input_cell.full_name, 
                          num_code_files: input_cell.num_code_files,
                          project_id: project.id
                          )
    puts "Creating #{input_cell.name}"
    folders_cache[input_cell.full_name] = input_cell.active_record_object
  end
  input_cell.children.each do |child|
    create_folders( child, folders_cache, project )               
  end      
end

def do_work( c, project )
    if CLEAN
      SubFolder.destroy_all
      Folder.destroy_all
      DisplayBoxLine.destroy_all
      DisplayBox.destroy_all
      DisplayBoxLink.destroy_all
    end
    
    folders_cache={}    
    create_folders( c, folders_cache, project )

    g_tree = GraphicalDirectoryTreeBuilder.new(c)
    g_tree.process
    # byebug
    lane_coll = SwimLaneCollection.new( g_tree )
    lane_coll.build
    lane_coll.assign_x_axis
    lane_coll.setup_links
    box_index = 0
        
    navigator_above = SwimLaneNavigator.new( lane_coll.all_rows[0] )
    db = DisplayBox.create( navigator_above.lane(0).as_hash( 0, box_index, 0).merge( project_id: project.id ) )
    navigator_above.lane(0).store_display_box(0, db )
    box_index += 1
    
    i = 1
    while( i < lane_coll.all_rows.count)
# byebug
      row_below = lane_coll.all_rows[i]
      navigator_below = SwimLaneNavigator.new( row_below )
      
      navigator_below.iterate_cell do |lane_below, lane_idx_below, cell_below, cell_idx_below|
        next if cell_below === :nil_column 
        
        db = DisplayBox.create( lane_below.as_hash( i, box_index, cell_idx_below).merge( project_id: project.id ) )
        lane_below.store_display_box(cell_idx_below, db )
        puts "#{cell_below.name} #{box_index}" if !cell_below.is_a? Symbol
        box_index += 1
      end
      
      # byebug
       navigator_above.iterate_cell do |lane_above, lane_idx_above, cell_above, cell_idx_above|
          links = lane_above.links[cell_idx_above]
          next if !links
          links.each do |link|
              next if !link
              cell_below_display_id = navigator_below.find_by_link( link )
              DisplayBoxLink.create( from:        lane_above.get_box_index( cell_idx_above ),
                                      to:         cell_below_display_id,
                                      project_id: project.id
                                      )
                                       
          end
        end  
        navigator_above = navigator_below
        i += 1
    end
    folders_cache
end

  
  desc "This task generates the data model for a C++ project"
  task generate_cpp: :environment do
    
    FOLDER = "/Users/darrylclarke/prj/source/code_small"
    FOLDER_BIGG = "/Users/darrylclarke/prj/source/xenia/src/xenia"
    FOLDER_BIG = "/Users/darrylclarke/prj/source/xenia/src/xenia/app"
    input = FOLDER
    
    c = DirCellTreeFactory.create( input )
    CellPrinter.output c
    #CellPrinter.process
    
    # byebug
    
    name = input.split('/').last
    project = Project.find_by_name( name )
    project ||= Project.create( name: name, root_path: input )
    
    # byebug
    folders_cache = do_work( c, project )
    
    if true
    classes_cache = {}
    
    if CLEAN
      Variable.destroy_all
      CodeMethod.destroy_all
      CodeClass.destroy_all
      CodeFile.destroy_all
    end
    
    q = DetailsFileFinder.new 
    q.set_tree( c )
    q.start
    # byebug
    
    q.list.each do |cell|
      # folder = cell.get_folder_full_path
      #   byebug
      # if folders_cache[folder] == nil
      #   folders_cache[ folder ] = Folder.create( name: cell.folder_name, path: folder ) # The root path
      # end
      
      cf = CodeFile.create( name: cell.bare_file_name,
                            path: cell.full_name,
                            project: project,
                            # folder: folders_cache[ folder ] 
                            folder: cell.parent.active_record_object 
                            ) 
      cell.active_record_object = cf    
                 
      sub_cell = cell.children[0]
      # byebug
      sub_cell.children.each do |code_cell|
        puts code_cell.class
        if code_cell.class == VariableCell
            puts "Doing #{code_cell.class}."
            puts code_cell.name
            Variable.create(  name:       code_cell.name,
                              var_type:   code_cell.type,
                              code_file:  cf,
                              line:       code_cell.line
                              )

        elsif code_cell.class ==  MethodCell
            CodeMethod.create(  name:                 code_cell.name,
                                code_file:            cf,
                                signature_line:       code_cell.line,
                                impl_start:           code_cell.impl_start_line,
                                impl_end:             code_cell.impl_end_line,
                                arguments:            code_cell.args,
                                specified_class_name: code_cell.class_name,
                                return_type:          code_cell.type
                                )
          
        elsif code_cell.class == ClassCell && code_cell.type == "class"
            newly_created = CodeClass.create(  name:         code_cell.name,
                                               code_file:    cf,
                                               line:         code_cell.line,
                                               ancestors:    code_cell.ancestors
                                               )

            classes_cache[ code_cell.name ] = newly_created
            code_cell.children.each do |item|
              
              if( item.class == VariableCell )
                var = item
                Variable.create(  name:       var.name,
                                  var_type:   var.type,
                                  code_file:  cf,
                                  line:       var.line
                                  )
            
              elsif( item.class == MethodCell )
                method = item
                puts "&&&&&&&&&&&& #{method.name} &&&&&&&&&&&&&&"
                CodeMethod.create(  name:                 method.name,
                                    code_file:            cf,
                                    impl_start:           method.impl_start_line,
                                    impl_end:             method.impl_end_line,
                                    arguments:            method.args,
                                    specified_class_name: newly_created.name,
                                    return_type:          method.type
                                    )
              end # if Variable / Method
            end #children  
        end # elsif class
      end # main children do
    end # file do     
    puts "********************************************************************************************************"
    puts "*                                  Linking methods to classes                                          *"
    puts "********************************************************************************************************"
    CodeMethod.all.where.not(specified_class_name:nil).each do |method|
      method.code_class = classes_cache[ method.specified_class_name ]
      method.save
      print "."
    end
    end #if false
    
    # CodeMethod.all.where(specified_class_name:nil).each do |method|
    #   if( method.impl_start <= method.impl_end )
    #     byebug
    #     method.code_class = classes_cache[ method.name ]
    #     method.save
    #     print ':'
    #   end
    # end
    
    puts
    print Cowsay::say("Done processing #{input}.")
    # q.pprint
  end #task do
end #ns 
