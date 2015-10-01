# require "file_parser.rb"
# require "./lib/file_scope_cell.rb"
require "/Users/darrylclarke/prj/clarity/lib/tasks/lib_require.rb"

def fifo1_cpp_parser_spec
	Fifo.factory(
		"namespace xcf {", 
		"template < def<T> > class abc : public ghi {",
		"public:",
		"int a;",
		"private:",
		"int b;",
		"}",
		"}")
end

def fifo2_cpp_parser_spec
	Fifo.factory(
		"namespace xcf_dc1 {", 
		"template < def<T> > class abc : public ghi {",
		"protected:",
		"abc( int x ) {",
		"x++;",
		"}",
		"virtual ~abc() {}",
		"virtual ~dtor2();",
		"int alpha;",
		"int beta;",
		"}",
		"}")
end

def fifo3_cpp_parser_spec
	Fifo.factory(
		"namespace xcf {", 
		"template < def<T> > class abc : public ghi {",
		"protected:",
		"abc( int x ) {",
		"x++;",
		"}",
		"virtual ~abc() {}",
		"int alpha;",
		"namespace inner {",
		"int beta;",
		"}",
		"}",
		"}")
end

def run_cpp_parser( str )
	f = Fifo.factory( str )
	f.find_multiple('{;}')
	result = CppParser.get_structure( f )
end
	
def run_cpp_scope( str )
	f = Fifo.factory( str )
	f.find_multiple('{;}')
	result = CppParser.get_scope( f )
end
	
RSpec.describe FileParser do
   #let (:parser) { parser = FileParser.new("", fifo1_cpp_parser_spec.data) }
   let (:parser2) { parser2 = FileParser.new("", fifo2_cpp_parser_spec.data) }
   let (:parser3) { parser3 = FileParser.new("", fifo3_cpp_parser_spec.data) }
   
   describe "get_scope" do
   		it "matches public" do
		   expect( run_cpp_scope "public: //ksdfs" ).to eq(:public)
		end
		
   		it "matches protected" do
		   expect( run_cpp_scope "protected: //ksdfs" ).to eq(:protected)
		end
		
   		it "matches private" do
		   expect( run_cpp_scope "private: //ksdfs" ).to eq(:private)
		end
		
   		it "doesn't matche public when it isn't there" do
		   expect( run_cpp_scope "another_goto_label: //ksdfs" ).to eq(false)
		end
   end
   
   describe 'get_structure' do
   
   		it "matches a struct with no name OK " do
		   result = run_cpp_parser "struct {"
		   expect( result ).to eq(["struct", "", nil])
		end
		   
   		it "matches a simple class" do
		   result = run_cpp_parser "class abc{"
		   expect( result ).to eq(["class", "abc", nil])
		end
		
		it "matches a class with inheritance" do
		   result = run_cpp_parser "class abc : public def {"
		   expect( result ).to eq(["class", "abc", "public def"])
		end
		
		it "matches a class with multiple inheritance" do
		   f = Fifo.factory("class abc : public def, ghi {")
		   f.find_multiple('{;}')
		   result = CppParser.get_structure( f )
		   expect( result ).to eq(["class", "abc", "public def, ghi"])
		end
		
		it "matches a class with templates"  do
		   f = Fifo.factory("template <T> class abc : public def {")
		   f.find_multiple('{;}')
		   result = CppParser.get_structure( f )
		   expect( result ).to eq(["class", "abc", "public def"])
		end
		
		it "matches a class with two templates" do
		   f = Fifo.factory("template < def<T> > class abc : public ghi {")
		   f.find_multiple('{;}')
		   result = CppParser.get_structure( f )
		   expect( result ).to eq(["class", "abc", "public ghi"])
		end
   
   end
   		
   describe "runs ok" do
   
   		it "reads everything and doesn't crash and has one child" do
		   parser = FileParser.new("", fifo1_cpp_parser_spec.data)
		   result = parser.process
   		   expect( result.children.length ).to eq(1)
		end
		
   		it "reads everything with one child that is a ClassCell" do
		   parser = FileParser.new("", fifo1_cpp_parser_spec.data)
		   result = parser.process
   		   expect( result.children[0].class ).to eq( ClassCell )
		end
		
		it "reads the class as gets the three pieces right" do
		parser = FileParser.new("", fifo1_cpp_parser_spec.data)
			result = parser.process.children[0]
			expect( result.name ).to eq("abc")
			expect( result.type ).to eq("class")
			expect( result.ancestors ).to eq("public ghi")
			expect( result.children.count ).to eq(2)
		end
	
		it "has int a;  as public" do
		parser = FileParser.new("", fifo1_cpp_parser_spec.data)
			result = parser.process.children[0].children[0]
			expect( result.type ).to eq("int")
			expect( result.name ).to eq("a")
			expect( result.body_lines[0].text ).to eq("int a;")
			expect( result.scope ).to eq(:public)
			expect( result.namespace ).to eq("xcf")
		end
		
		it "has int b;  as private" do
		parser = FileParser.new("", fifo1_cpp_parser_spec.data)
			result = parser.process.children[0].children[1]
			expect( result.type ).to eq("int")
			expect( result.name ).to eq("b")
			expect( result.body_lines[0].text ).to eq("int b;")
			expect( result.scope ).to eq(:private)
			expect( result.namespace ).to eq("xcf")
		end
				
   end
   describe "Reads ctor dtor OK" do
   
   	   let (:dtor_test) { dtor_test = FileParser.new("", Fifo.factory(
							"MyClass::~MyClass() {",
							"}",
							"virtual MyClass2::~MyClass2() {",
							"abc",
							"}"
	         ).data) }
			
   		it "simple class with destructor" do
		   result = parser2.process
   		   expect( result.children.length ).to eq(1)
		end

  		it "reads everything and doesn't crash and has one child" do
		   result = parser2.process
   		   expect( result.children.length ).to eq(1)
		end
		
   		it "reads everything with one child that is a ClassCell, and has 4 children" do
		   result = parser2.process
		   #FileScopeCell.dump( result )
   		   expect( result.children[0].class ).to eq( ClassCell )
		   expect( result.children[0].children.count ).to eq(5)
		end
		
		it "reads the class as gets the three pieces right" do
			result = parser2.process.children[0]
			expect( result.text ).to eq("abc")
			expect( result.type ).to eq("class")
			expect( result.ancestors ).to eq("public ghi")
		end
	
   		it "reads everything with 4 sub-children all protected" do
		   #FileScopeCell.dump( parser2.process )
		   result = parser2.process.children[0].children
		   result2 = result.map{ |x| x.scope }
   		   expect( result2 ).to eq( [ :protected, :protected, :protected, :protected, :protected ] )
		end
		
	   	it "reads everything with 4 sub-children all with proper namespaces" do
		   #FileScopeCell.dump( parser3.process )
		   result = parser3.process.children[0].children
		   result = result.map{ |x| x.namespace }
   		   expect( result ).to eq( [ "xcf", "xcf", "xcf", "xcf::inner" ] )
		end
		
		it "understands dtor notation" do
			result = CppParser.get_method_implementation("MyClass::~MyClass() {")
			expect( result[0] ).to eq("")
			expect( result[1] ).to eq("MyClass::~MyClass")
			expect( result[2] ).to eq("()")
		end
		
		it "has the ~ in the right place for the inline destructor" do
			result = parser2.process.children[0].children[1]
			expect( result.name ).to eq("~abc")
			expect( result.type.index("virtual") ).to be 
		end		
		
		it "has the ~ in the right place for the inline destructor 2" do
			result = parser2.process
			result = FileScopeCell.find( result, "~dtor2")
			expect( result ).to be
			expect( result.type ).to eq("virtual")
			expect( result.args ).to eq("()")
		end
		
		it "has the ~ in the right place for externally defined destructors" do
			result = dtor_test.process
			result = result.children[0]
			expect( result.name ).to eq("~MyClass")
			expect( result.class_name ).to eq("MyClass")
			expect( result.args ).to eq("()")
	    end
		
		it "has the ~ in the right place for externally defined destructors" do
			result = dtor_test.process.children[1]
			expect( result.name ).to eq("~MyClass2")
			expect( result.class_name ).to eq("MyClass2")
			expect( result.args ).to eq("()")
			expect( result.type ).to eq("virtual")
	    end
		
		it "make sure the ~ doesn't get in the way for other methods" do
			result = parser2.process.children[0].children[0]
			expect( result.name ).to eq("abc")
			expect( result.type.index("virtual") ).to_not be 
		end
		
		it "deals with other keywords like override = default in the dtor signature" do
			str = "~Win32Semaphore() override = default;"
			result = CppParser.prune_string_remove_unnecessary_stuff( str )
			expect( result[:string] ).to eq("~Win32Semaphore();")
		end
		
		it "deals with other methods with =default" do
			str = "be() = default;"
			result = CppParser.prune_string_remove_unnecessary_stuff( str )
			expect( result[:string] ).to eq('be();');
		end
		
		it "deals with other methods with =default" do
			str = "be() = default {"
			result = CppParser.prune_string_remove_unnecessary_stuff( str )
			expect( result[:string] ).to eq('be() {');
		end
		
		it "deals with other methods with override" do
			str = "be() override;"
			result = CppParser.prune_string_remove_unnecessary_stuff( str )
			expect( result[:string] ).to eq('be();');
		end
		
		it "deals with other methods with override" do
			str = "be() override {"
			result = CppParser.prune_string_remove_unnecessary_stuff( str )
			expect( result[:string] ).to eq('be() {');
		end

		it "deals with other methods with override = default 1" do
			str = "be() override = default;"
			result = CppParser.prune_string_remove_unnecessary_stuff( str )
			expect( result[:string] ).to eq('be();');
		end
		
		it "deals with other methods with override = default 2" do
			str = "be() override = default {"
			result = CppParser.prune_string_remove_unnecessary_stuff( str )
			expect( result[:string] ).to eq('be() {');
		end		
		
		it "deals with sizeof() operator in variable definition with assignment." do
			str = "static const uint32_t frame_size_ = sizeof(float) * frame_samples_;"
			result = CppParser.is_method_forward_decl?( str )
			expect( result ).to_not be
		end
		
		it "deals with typedef OK" do 	
			str = "typedef std::function<void(Args...)> Listener;"
			result = CppParser.is_typedef?(str)
			expect( result ).to be
		end
	end
	
	describe "Tell variables from methods" do
	
		it "Knows it is a method forward declaration" do
			expect( CppParser.is_method_forward_decl?("int abcdeft( int i = 0);")).to be
		end
		
		it "Knows it isn't a method forward declaration" do
			expect( CppParser.is_method_forward_decl?("int abcdeft( int i = 0){;}")).to_not be
		end
		
		it "Knows it is a Variable" do
			expect( CppParser.is_variable_declaration?("int abcdeft = 1;")).to be
			expect( CppParser.is_variable_declaration?("int abcdeft;")).to be
			expect( CppParser.is_variable_declaration?("int abcdeft();")).to_not be
		end
	end			
	
	describe "Deal with empty method implementations" do
	
	   let (:parser4) { parser4 = FileParser.new("", Fifo.factory(
			"template < def<T> > class abc : public ghi {",
			"protected:",
			"abc123( int x ) {",
			"}",
			"virtual ~abc() {}",
			"float noImpl( float i, vector<int> j);",
			"}"		   
	   ).data) }
	
		it "inserts an empty string when there is nothing in the {} block on two lines" do
			result = parser4.process
			result = FileScopeCell.find( result, "abc123" )
			expect( result.has_impl? ).to be
		end
		
		it "inserts an empty string when there is nothing in the {} block on two lines" do
			result = parser4.process
			result = FileScopeCell.find( result, "~abc" )
			expect( result.has_impl? ).to be
		end

		it "Doesn't insert an empty string when there is no {} block an a semicolon instead" do
			result = parser4.process
			result = FileScopeCell.find( result, "noImpl" )
			expect( result.has_impl? ).to_not be
		end
	end
	
	describe "Parse class names" do
	
	   let (:parser5) { parser5 = FileParser.new("", Fifo.factory(
			"void Memory::abc123( int x ) {",
			"}",
			"void NoClass( int x ) {",
			"}",
	   ).data) }
	
		it "Gets the class name 'Memory' from the method signature" do
			str = "Memory::abc123"
			result = CppParser.get_class_name( str )
			expect( result ).to eq(["Memory", "abc123"])
		end
	
		it "Doesn't gets the class name from the method signature when there isn't one" do
			str = "abc123"
			result = CppParser.get_class_name( str )
			expect( result ).to eq([nil, "abc123"])
		end
		
		it "Parses the method name 'abc123' from the method signature" do
			result = parser5.process
			result = FileScopeCell.find( result, 'abc123' )
			expect( result ).to be
		end		
				
		it "Parses the class name 'Memory' from the method signature" do
			result = parser5.process
			result = FileScopeCell.find( result, 'abc123' )
			expect( result.class_name ).to eq("Memory")
		end		
				
		it "Doesn't parse the class name from the method signature when there isn't one" do
			result = parser5.process
			result = FileScopeCell.find( result, 'NoClass' )
			expect( result ).to be
		end		
	end	
	
	describe "Tracking line numbers for methods" do
		
	   let (:parser6) { parser6 = FileParser.new("", Fifo.factory(
		"namespace xcf {", 
		"template < def<T> > class abc : public ghi {",
		"protected:",
		"abcm( int x ) {",
		"x++;",
		"x++;",
		"if(true){",
		"x++;",
		"}",
		"x++;",
		"x++;",
		"}",
		"virtual ~abc() {}",
		"int alpha;",
		"int beta;",
		"}",
		"}"
	         ).data) }
		it "has the right start and end lines for method abc" do
			result = parser6.process
			result = FileScopeCell.find( result, "abcm" )
			expect( result.impl_start_line ).to eq(5)
			expect( result.impl_end_line ).to eq(11)
		end
		
		
		it "has the right start and end lines for method ~abc" do
			result = parser6.process
			result = FileScopeCell.find( result, "~abc" )
			expect( result.impl_start_line ).to eq(13)
			expect( result.impl_end_line ).to eq(13)
		end
	end	
	
	describe "Handling pure virtual functions" do
	
	   let (:parser7) { parser7 = FileParser.new("", Fifo.factory(
		"namespace xcf {", 
		"template < def<T> > class abc : public ghi {",
		"protected:",
		"int abczed( int x ) = 0;",
		"int def( int x )      =      0      ;",
		"int ghi( int x )=0        ;",
		"virtual ~abc() {}",
		"int alpha;",
		"int beta;",
		"}",
		"}"
	         ).data) }
		# it "doesn't fail when parsing a pure virtual function"
		
		# it "properly parses the string" do
		# 	result = CppParser.is_pure_virtual?( "int xyz( int i ) = 0;" )
		# 	expect( result ).to be
		# end
		
		it "stores an flag - abstract - when it finds () = 0;" do
			result = parser7.process
			result = FileScopeCell.find( result, "abczed" );
			expect( result.abstract ).to be
		end
		
		it "variation 2 - stores an flag - abstract - when it finds () = 0;" do
			result = parser7.process
			result = FileScopeCell.find( result, "def" );
			expect( result.abstract ).to be
		end
			
		it "variation 3 - stores an flag - abstract - when it finds () = 0;" do
			result = parser7.process
			result = FileScopeCell.find( result, "ghi" );
			expect( result.abstract ).to be
		end
	end
	
	describe "Test prune_string_remove_unnecessary_stuff" do
	
		it "tests case #1" do 
			s = "void xyz( int a = 5 ) = 0;"
			result = CppParser.prune_string_remove_unnecessary_stuff( s )
			expect( result[:is_abstract] ).to eq(true)
			expect( result[:string]      ).to eq("void xyz( int a = 5 );")
		end
		
		it "tests case #2" do 
			s = "void xyz( int a = 5 ) const;"
			result = CppParser.prune_string_remove_unnecessary_stuff( s )
			expect( result[:doing_const] ).to eq(true)
			expect( result[:string] ).to eq("void xyz( int a = 5 );")
		end
		
		it "tests case #3" do 
			s = "void xyz( int a = 5 ) = default;"
			result = CppParser.prune_string_remove_unnecessary_stuff( s )
			expect( result[:string] ).to eq("void xyz( int a = 5 );")
		end
		
		it "tests case #4" do 
			s = "void xyz( int a = 5 ) override;"
			result = CppParser.prune_string_remove_unnecessary_stuff( s )
			expect( result[:string] ).to eq("void xyz( int a = 5 );")
		end
		
		it "tests case #5" do 
			s = "void xyz( int a = 5 ) override = default;"
			result = CppParser.prune_string_remove_unnecessary_stuff( s )
			expect( result[:string] ).to eq("void xyz( int a = 5 );")
		end
	end
	
	describe "CppParser.get_structure tests" do
		it "handles complex strings ok" do
			s = "template <typename class T_parser8a>  class object_ref : public skdkdl, kskdk"
			result = CppParser.get_structure( s )
			expect( result[0] ).to eq("class")
			expect( result[1] ).to eq("object_ref")
			expect( result[2] ).to eq("public skdkdl, kskdk")
		end
		
		it "handles class forward declarations ok" do
			expect( CppParser.get_structure("class xyz;") ).to_not be
		end
	end
	
	describe "Handling templates" do

	   let (:parser8a) { parser8a = FileParser.new("", Fifo.factory(
"template <typename T> ",	
"class object_ref {",
" public:",
"  object_ref2() noexcept {}",
"}"
	         ).data) }
			
	   let (:parser8b) { parser8b = FileParser.new("", Fifo.factory(
"template <typename T> class object_ref {",
" public:",
"  object_ref2() noexcept : value_(nullptr) {}",
"}"
	         ).data) }
			
						
	   let (:parser8c) { parser8c = FileParser.new("", Fifo.factory(
"template <typename T_parser8a>",
"class object_ref {",
" public:",
"  object_ref2() noexcept : value_(nullptr) {}",
"  object_ref(std::nullptr_t) noexcept  // NOLINT(runtime/explicit)",
"      : value_(nullptr) {}",
"  object_ref& operator=(std::nullptr_t) noexcept {",
"    reset();",
"    return (*this);",
"  }",
"  template <class V, class = typename std::enable_if<",
"                         std::is_convertible<V*, T*>::value, void>::type>",
"  object_ref(const object_ref<V>& right) noexcept {",
"    reset(right.get());",
"    if (value_) value_->Retain();",
"  }",
"}"
	         ).data) }
		
		it "Processes templates 8a properly" do
			result = parser8a.process
			result2 = FileScopeCell.find( result, "object_ref" );
			expect( result2 ).to be
			result3 = FileScopeCell.find( result, "object_ref2" );
			expect( result3 ).to be
		end
		
		it "Processes templates 8b properly" do
			result = parser8b.process
			result = FileScopeCell.find( result, "object_ref" );
			expect( result ).to be
		end
		
		it "Processes templates 8c properly" do
			result = parser8c.process
			result = FileScopeCell.find( result, "object_ref" );
			expect( result ).to be
		end		
		
		it "doesn't make a method into a class def'n" do
			str = "template <class V, class = typename std::enable_if<     std::is_convertible<V*, T*>::value, void>::type>   object_ref(const object_ref<V>& right) noexcept {"
			result = CppParser.get_structure( str )
			expect( result ).to_not be
		end
		
		it "interprets this as a method" do
			str = "template <class V, class = typename std::enable_if<     std::is_convertible<V*, T*>::value, void>::type>   object_ref(const object_ref<V>& right) noexcept {"
			fields_and_data = CppParser.prune_string_remove_unnecessary_stuff( str )	
			str2 = fields_and_data[:string]
			text_array = CppParser.get_method_implementation( str2 )
			
			expect( text_array[0] ).to eq("template <class V, class = typename std::enable_if<     std::is_convertible<V*, T*>::value, void>::type>")
			expect( text_array[1] ).to eq("object_ref")
			expect( text_array[2] ).to eq("(const object_ref<V>& right)")
		end
		 	
	
	end	
end