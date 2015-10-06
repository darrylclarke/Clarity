class CodeFile < ActiveRecord::Base
  belongs_to :project
  belongs_to :folder
  has_many   :code_methods, dependent: :destroy
  has_many   :variables, dependent: :destroy
  has_many   :code_classes, dependent: :destroy
  
  validates :name, presence: true
  validates :path, presence: true
  validates :project_id, presence: true
end
