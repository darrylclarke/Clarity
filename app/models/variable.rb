class Variable < ActiveRecord::Base
  belongs_to :code_file
  belongs_to :code_class
  belongs_to :code_namespace
  belongs_to :project 
  
  validates :name, presence: true
  validates :var_type, presence: true
  validates :code_file_id, presence: true
  validates :line, numericality: {greater_than_or_equal_to: 1 }
  
  
  def self.by_project_and_namespace( project_id, namespace_id = nil )
    if( namespace_id )
      where(project_id: project_id, code_namespace_id: namespace_id ).order(:name)
    else
      where(project_id: project_id ).order(:name)
    end
  end
  
end
