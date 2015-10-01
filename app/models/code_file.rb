class CodeFile < ActiveRecord::Base
  belongs_to :project
  has_many   :code_methods
  has_many   :variables
  has_many   :code_classes
  
  validates :name, presence: true
  validates :path, presence: true
  validates :project_id, presence: true
end
