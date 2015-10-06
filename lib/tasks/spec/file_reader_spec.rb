# in spec/calculator_spec.rb
# require "file_reader"
require "/Users/darrylclarke/prj/clarity/lib/tasks/lib_require.rb"


RSpec.describe FileReader do
	
	def setup_1
		data = Array.new
		data << "// hello"
		data << "int i = /* 33 */3;   "
		data << "#define x /*   */    \t  y // akdkdsksdfkj"
		data
	end
		
	describe 'creation' do
		it 'reads two lines properly' do
			fr = FileReader.new
			lines = fr.load( setup_1, true )
			expect(lines[0].text).to eq('int i = 3;')
			expect(lines[0].line).to eq(2)
			expect(lines[1].text).to eq('#define x y')
			expect(lines[1].line).to eq(3)
		end
	end
	
	describe 'splitting' do
		before do             #  01234567890123
			@line = Line.new(5, "{12345;67890}")
		end
		it 'splits on unknown character ok' do
			pos = @line.find('*')
			expect( pos ).to be_nil
		end
		
		it 'splits on known character ok' do
			pos = @line.find(';')
			expect( pos ).to eq( 6 )
		end
		
		it 'splits a line into two pieces properly in the middle of the line' do
			pos = @line.find(';')
			expect( @line.before!(pos).text ).to eq("{12345;")
			expect( @line.text ).to eq('67890}')
		end
		
		it 'splits a line into two pieces properly at the end of the line 1'  do
			pos = @line.find('}')
			l2 = Line.new( @line )
			l3 = @line.before!( pos )
			expect( l3.text ).to eq(l2.text)
			expect( @line.text ).to be_nil
		end
		
		it 'splits a line into two pieces properly at the end of the line-2'  do
			pos = @line.find('0')
			l2 = Line.new( @line )
			expect( @line.before!(pos).text ).to eq('{12345;67890')
			expect( @line.text ).to eq("}")
		end
	
		it 'splits properly at the beginning of the line'  do
			pos = @line.find('{')
			expect( @line.before!(pos).text ).to eq("{")
			expect( @line.text ).to eq('12345;67890}')
		end
		
		it 'finds multiple ok' do
			pos_array = @line.find_multiple("{;}")
			expect( @line.find_multiple("{;}") ).to eq([0,'{'])
			expect( @line.find_multiple("#;}") ).to eq([6,';'])
			expect( @line.find_multiple("*}&") ).to eq([12,'}'])
			expect( @line.find_multiple("*\#()YYESE&") ).to eq([nil,nil])
		end
	end
	
	describe 'get lines a-->b' do
		let(:f)     { f = FileReader.new }
		let(:lines) { lines = f.get_lines_a_to_b(__FILE__, 1, 2 ) }
		
		it "reads the first two lines of this file" do
			expect( lines.length ).to eq(2)
		end
		
		it "reads the text of the first line OK" do
			expect( lines[0].line ).to eq(1)
			expect( lines[0].text ).to eq("# in spec/calculator_spec.rb")
		end
		
		it "reads the text of the second line OK" do
			expect( lines[1].line ).to eq(2)
			expect( lines[1].text ).to eq("# require \"file_reader\"")
		end
		
	end	
end