# require "file_parser.rb"
# require "file_scope_cell.rb"
require "/Users/darrylclarke/prj/clarity/lib/tasks/lib_require.rb"

def fifo1_cpp_parser_spec_const
	Fifo.factory(
		"namespace outer {", 
		"namespace inner {",
		"class abc< def<T> > : public ghi {",
		"public:",
		"const int constVar1 = 5;",
		"static unsigned int constMethod123_x (int a, int b) const {",
		"doSomething(a,b);",
		"}",
		"private:",
		"int b;",
		"}",
		"}",
		"const int constVar2 = 17;",
		"}")
end

RSpec.describe FileParser do
   let (:parser) { parser = FileParser.new("", fifo1_cpp_parser_spec_const.data) }
   
   describe "Reads const variables OK" do
   		it "Reads const variables constVar1 OK" do
		   result = parser.process
		   cell = FileScopeCell.find( result, "constVar1")
		   # FileScopeCell.dump( cell, 0 )
		   expect( cell ).to be
		   expect( cell.const ).to eq(true)
		end
		
   		it "Reads const variables constVar2 OK" do
		   result = parser.process
		   cell = FileScopeCell.find( result, "constVar2")
		   expect( cell ).to be
		   expect( cell.const ).to eq(true)
		end
   end
   		
   describe "runs ok" do
   		it "has primitives that deal with const non-mutating methods ok" do
		   s  = "static unsigned int constMethod123_x (int a, int b) const {"
		   result = CppParser.prune_string_remove_unnecessary_stuff( s )
		   expect( result[:string] ).to eq("static unsigned int constMethod123_x (int a, int b) {")
		 end
		   
     	it "has primitives that deal with const non-mutating methods ok" do
		   s  = "static unsigned int constMethod123_x (int a, int b) const {"
		   result = CppParser.prune_string_remove_unnecessary_stuff( s )
		   result = result[:string]
		   result = CppParser.get_method_implementation( result )
		   expect( result[0] ).to eq("static unsigned int")
		   expect( result[1] ).to eq("constMethod123_x")
		   expect( result[2] ).to eq("(int a, int b)")
		 end
		   
   		it "reads a 'does const' method properly"  do
			result = parser.process
			cell = FileScopeCell.find( result, "constMethod123_x" )
			expect( cell ).to be
			expect( cell.doing_const ).to eq(true) 
		end
   end
end