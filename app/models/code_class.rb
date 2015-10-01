class CodeClass < ActiveRecord::Base
  belongs_to :code_file
  has_many   :code_methods
  has_many   :variables
  
  validates :name, presence: true
  validates :code_file_id, presence: true
  validates :line, numericality: {greater_than_or_equal_to: 1 }
end
