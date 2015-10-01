# require "./lib/tasks/lib_require.rb"

class Tools
	JUST_WIDTH = 3
	def self.r_just( input )
		s = input.to_s
		num = JUST_WIDTH - s.length
		if num > 0
			' '*num + s
		else
			s
		end
	end
end

class Integer
	def r_just
		Tools.r_just(self) + " : "
	end
end

class Fixnum
  def is_valid?
    self >= 0
  end
end

class NilClass
  def is_valid?
    false
  end
  def r_just
	  nil 
  end
end
