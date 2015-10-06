class Folder < ActiveRecord::Base

  has_many :sub_folders, dependent: :destroy, foreign_key: "parent_id"
  has_many :children, through: :sub_folders,  source: :folder
  
  has_many :inverse_ownerships, dependent: :nullify, class_name: "SubFolder", foreign_key: "folder_id"  
  has_many :owned_by, through: :inverse_ownerships, source: :parent
  
  	
  has_many :code_files,  dependent: :nullify
  has_one  :display_box, dependent: :nullify
end
