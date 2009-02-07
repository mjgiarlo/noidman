class Contract < ActiveRecord::Base
  has_many :identifiers
  validates_presence_of :statement, :label
end
