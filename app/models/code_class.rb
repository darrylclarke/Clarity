class CodeClass < ActiveRecord::Base
  belongs_to :code_file
  belongs_to :code_namespace
  belongs_to :project 
  
  has_many   :code_methods
  has_many   :variables
  
  validates :name, presence: true
  validates :code_file_id, presence: true
  validates :line, numericality: {greater_than_or_equal_to: 1 }
  
  
  def self.by_project_and_namespace( project_id, namespace_id = nil )
    if( namespace_id )
      where(project_id: project_id, code_namespace_id: namespace_id )
    else
      where(project_id: project_id )
    end
  end
  
end
