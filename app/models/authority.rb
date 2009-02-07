class Authority < ActiveRecord::Base
  has_many :minters
  validates_presence_of :number, :label
  validates_uniqueness_of :number
  validates_numericality_of :number
end
