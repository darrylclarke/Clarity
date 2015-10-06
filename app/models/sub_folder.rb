class SubFolder < ActiveRecord::Base
  belongs_to :parent, class_name: "Folder"
  belongs_to :folder, class_name: "Folder"
end
