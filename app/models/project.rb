class Project < ActiveRecord::Base
  has_many :user_projects, dependent: :nullify
  has_many :contributing_users, through: :user_projects, source: :user
  
  has_many :code_files,      dependent: :destroy
  has_many :folders,         dependent: :destroy
  has_many :code_namespaces, dependent: :destroy
  has_many :code_classes,    dependent: :destroy 
  has_many :code_methods,    dependent: :destroy 
  has_many :variables,       dependent: :destroy 
  
  validates :name,      presence: true#, uniqueness: true
  validates :root_path, presence: true#, uniqueness: true

end
