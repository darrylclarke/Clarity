# require "fifo.rb"
# require "file_reader.rb"
require "/Users/darrylclarke/prj/clarity/lib/tasks/lib_require.rb"

# Fifo


RSpec.describe Fifo do
    
    def fifo1
        Fifo.factory(
            "one",    
            "two=two",
            "three",  
            "four",   
            "fi,ve")
    end

    def fifo2
        Fifo.factory(
            "namespace xcf {", 
            "{ ",
           # 01234567890
            "    Void foo( int x ){",
            "       Foo2();",
            "    }", 
            "}",
            "}")
    end
    def fifo_no_foo
        Fifo.factory(
            "namespace xcf {", #  
            "{ ",
           # 01234567890
            "    Void foo ( int x ){",
            "       a = 5;",
            "    }", 
            "}",
            "}")
    end
    
    def enum_fifo
        f = fifo_no_foo
        f.data[0].text = "enum x {"
        f
    end
    
    def fifo_equals
       Fifo.factory("int x = {", "{1,2,3},", "}")
    end
    
    def ns_regex
        /namespace\s*[_0-9a-zA-Z]*/
    end
    
    ENUM_REGEX = /enum\s*[_0-9a-zA-Z]*/
    EQUALS_REGEX = /[_0-9a-zA-Z]*\s\=/
        
        
    describe "breaks up the line properly" do
        
        let( :fifo )     { fifo1 }
        let( :line_new ) { fifo.find_multiple(',');fifo.before }
        
        it "finds a token in the last string and returns the first part" do 
            expect( line_new.text ).to eq("one two=two three four fi,")
        end
        
        it "does it" do
            expect( line_new.line ).to be( 1 )
            expect( line_new.text ).to eq( "one two=two three four fi," )             
        end   
        
    end
    
    describe "finds a character in the entire fifo and returns a match array." do
        let( :fifo  ) { fifo1 }
        let( :match ) { fifo.find(',=&')}
        
        it "has the character positition in match[1] == 3"  do
            expect( match[0] ).to eq(3)
        end
        
        it "has the character itself as '='" do
            expect( match[1] ).to eq('=')
        end
        
        it "has the line number match[2] == 1" do
            expect( match[2] ).to eq(1)
        end
        
    end
    
    describe "finds a regex in the entire fifo and returns a match array." do
    
        context "regex exists" do
            let( :fifo )  { fifo2 }
            let( :match ) { fifo.match(/[_0-9a-zA-Z]*\(/) }
            
            it "has the coordinates of the regex match with the index in pos 0 = 9" do
                expect( match[0] ).to eq(9)
            end
            
            it "has the regex match in pos 1" do
                expect( match[1] ).to eq('foo(')
            end
            
            it "has the coordinates of the regex match with the fifo line number in pos 2" do
                expect( match[2] ).to eq(2)
            end
        end
        
        context "namespace exist" do
            let( :fifo  ) { fifo_no_foo          }
            let( :match ) { fifo.match(ns_regex) }
            
            it "finds the namespace" do
                expect( match[0] ).to eq(0)
                expect( match[1] ).to eq('namespace xcf')
                expect( match[2] ).to eq(0)
            end
        end        
        context "enum exists" do
            let( :fifo  ) { enum_fifo              }
            let( :match ) { fifo.match(ENUM_REGEX) }
            
            it "finds the namespace" do
                expect( match[0] ).to eq(0)
                expect( match[1] ).to eq('enum x')
                expect( match[2] ).to eq(0)
            end
        end
        context "equals exists" do
            let( :fifo  ) { fifo_equals            }
            let( :match ) { fifo.match(EQUALS_REGEX) }
            
            it "finds the namespace" do
                expect( match[0] ).to eq(4)
                expect( match[1] ).to eq('x =')
                expect( match[2] ).to eq(0)
            end
        end
    end
    
    describe "get lines from reader" do
    
        it "reads lines until they are all gone then stops" do
            lines = fifo1.data
            fifo2 = Fifo.new 
            fifo2.load( fifo1.data )

            expect( fifo2.get_next ).to be
            fifo2.advance_to_end
            fifo2.transform_to_after!

            expect( fifo2.get_next ).to be
            fifo2.advance_to_end
            fifo2.transform_to_after!

            expect( fifo2.get_next ).to be
            fifo2.advance_to_end
            fifo2.transform_to_after!

            expect( fifo2.get_next ).to be
            fifo2.advance_to_end
            fifo2.transform_to_after!

            expect( fifo2.get_next ).to be
            fifo2.advance_to_end
            fifo2.transform_to_after!


            expect( fifo2.get_next ).not_to be
        end
    end

end