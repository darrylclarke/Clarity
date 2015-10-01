class Variable < ActiveRecord::Base
  belongs_to :code_file
  belongs_to :code_class

  validates :name, presence: true
  validates :var_type, presence: true
  validates :code_file_id, presence: true
  validates :line, numericality: {greater_than_or_equal_to: 1 }
end
