class CodeMethod < ActiveRecord::Base
  belongs_to :code_file
  belongs_to :code_class
  belongs_to :code_namespace
  belongs_to :project 
  
  has_many :impl_calls, dependent: :destroy, foreign_key: "caller_id"
  has_many :method_calls, through: :impl_calls,  source: :called
  
  has_many :inverse_callings, dependent: :nullify, class_name: "ImplCall", foreign_key: "called_id"  
  has_many :called_by, through: :inverse_callings, source: :caller
  
  validates :name, presence: true
  validates :code_file_id, presence: true
  validates :impl_start, numericality: {greater_than_or_equal_to: 1 }
  validates :impl_end,   numericality: {greater_than_or_equal_to: 1 }
  
  def self.by_project_and_namespace( project_id, namespace_id = nil )
    if( namespace_id )
      where(project_id: project_id, code_namespace_id: namespace_id ).order(:name)
    else
      where(project_id: project_id ).order(:name)
    end
  end
  
end
