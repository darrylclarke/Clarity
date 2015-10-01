class Project < ActiveRecord::Base
  has_many :user_projects, dependent: :nullify
  has_many :contributing_users, through: :user_projects, source: :user
  
  has_many :code_files
  
  validates :name, presence: true#, uniqueness: true
  validates :root_path, presence: true#, uniqueness: true

end
