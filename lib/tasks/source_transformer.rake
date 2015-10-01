require "./lib/tasks/lib_require.rb"

namespace :source_transformer do

  # in the case of generate_campaigns: :environment
  # the task name will be generate_campaigns and the :environment option makes
  # it load the Rails environment for this task
  
  desc "This task generates the data model for a C++ project"
  task generate_cpp: :environment do
    
    FOLDER = "/Users/darrylclarke/prj/source/code_small/hid"
    FOLDER_BIGG = "/Users/darrylclarke/prj/source/xenia"
    FOLDER_BIG = "/Users/darrylclarke/prj/source/xenia/src/xenia/app"
    input = FOLDER_BIG
    
    c = DirCellTreeFactory.create( input )
    CellPrinter.output c
    #CellPrinter.process
    
    byebug
    
    name = "Xenia 0.0.1"
    project = Project.find_by_name( name )
    project ||= Project.create( name: name, root_path: input )
    
    Variable.all.where.not(id:1).destroy_all
    CodeMethod.all.where.not(id:1).destroy_all
    CodeClass.all.where.not(id:1).destroy_all
    CodeFile.all.where.not(id:1).destroy_all
    classes_cache = {}
    
    q = DetailsFileFinder.new 
    q.set_tree( c )
    q.start
    q.list.each do |cell|
      cf = CodeFile.create( name: cell.bare_file_name,
                            path: cell.full_name,
                            project: project ) 
                            
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
          # name
          # var_type
          # code_file
          #  line 
        elsif code_cell.class ==  MethodCell
            CodeMethod.create(  name:                 code_cell.name,
                                code_file:            cf,
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
            # name
            # code_file
            # line
            # ancestors
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
