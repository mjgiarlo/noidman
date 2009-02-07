class User < ActiveRecord::Base
  has_and_belongs_to_many :roles
  has_many :identifiers
  validates_presence_of :name
end
