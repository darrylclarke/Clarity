# require "file_parser.rb"
require "/Users/darrylclarke/prj/clarity/lib/tasks/lib_require.rb"

def fifo1_nested_namespace
	Fifo.factory(
		"namespace outer {", 
		"namespace inner {",
		"template < def<T> > class abc : public ghi {",
		"public:",
		"int a;",
		"private:",
		"int b;",
		"}",
		"}",
		"int c;",
		"}")
end

def get_namespace( str )
	f = Fifo.factory( str )
	result = CppParser.get_namespace( f )
end
	
def run_cpp_scope( str )
	f = Fifo.factory( str )
	f.find_multiple('{;}')
	result = CppParser.get_scope( f )
end
	
RSpec.describe FileParser do
   let (:parser) { parser = FileParser.new("", fifo1_nested_namespace.data) }
   
   describe "get_namespace" do
   		it "matches abc" do
		   expect( get_namespace "namespace abc {" ).to eq("abc")
		end
   end
   		
   describe "runs ok" do
   
   		it "reads everything and doesn't crash and has one child" do
		   result = parser.process
   		   expect( result.children.length ).to eq(2)
		end
		
   		it "reads everything with one child that is a ClassCell and one that is a CodeElement" do
		   result = parser.process
   		   expect( result.children[0].class ).to eq( ClassCell )
   		   expect( result.children[1].class ).to eq( VariableCell )
		end
		
		it "reads the class as gets the three pieces right" do
			result = parser.process.children[0]
			expect( result.name ).to eq("abc")
			expect( result.type ).to eq("class")
			expect( result.ancestors ).to eq("public ghi")
			expect( result.children.count ).to eq(2)
		end
	
		it "has int a;  as public with the proper namespace" do
			result = parser.process.children[0].children[0]
			expect( result.name ).to eq("a")
			expect( result.body_lines[0].text ).to eq("int a;")
			expect( result.scope ).to eq(:public)
			expect( result.namespace ).to eq("outer::inner")
		end
		
		it "has int b;  as private with the proper namespace" do
			result = parser.process.children[0].children[1]
			expect( result.name ).to eq("b")
			expect( result.body_lines[0].text ).to eq("int b;")
			expect( result.scope ).to eq(:private)
			expect( result.namespace ).to eq("outer::inner")
		end
				
		it "has int c;  as public with the proper outer namespace" do
			result = parser.process.children[1]
			expect( result.body_lines[0].text ).to eq("int c;")
			expect( result.scope ).to eq(:global)
			expect( result.namespace ).to eq("outer")
		end
   end

end