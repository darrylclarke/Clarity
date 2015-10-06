class DisplayBox < ActiveRecord::Base
  belongs_to :folder
  
  # has_many :linked_boxes, dependent: :destroy, foreign_key: "parent_id"
  # has_many :children, through: :linked_boxes,  source: :display_box
  
  # has_many :inverse_ownerships, dependent: :nullify, class_name: "DisplayBoxLine", foreign_key: "display_box_id"  
  # has_many :linked_by, through: :inverse_ownerships, source: :parent
end
