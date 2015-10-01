class ImplCall < ActiveRecord::Base
	belongs_to :caller, class_name: "CodeMethod"
	belongs_to :called, class_name: "CodeMethod"
	
end
