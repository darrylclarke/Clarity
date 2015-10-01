class CodeMethod < ActiveRecord::Base
  belongs_to :code_file
  belongs_to :code_class

  has_many :impl_calls, dependent: :destroy, foreign_key: "caller_id"
  has_many :method_calls, through: :impl_calls,  source: :called
  
  has_many :inverse_callings, dependent: :nullify, class_name: "ImplCall", foreign_key: "called_id"  
  has_many :called_by, through: :inverse_callings, source: :caller
  
  validates :name, presence: true
  validates :code_file_id, presence: true
  validates :impl_start, numericality: {greater_than_or_equal_to: 1 }
  validates :impl_end,   numericality: {greater_than_or_equal_to: 1 }
end
